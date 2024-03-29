use v6;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use Math::FFT::Libfftw3::Common;
use Math::FFT::Libfftw3::Exception;

unit class Math::FFT::Libfftw3::R2R:ver<0.3.5>:auth<zef:FRITH> does Math::FFT::Libfftw3::FFTRole;

has num64     @.out;
has num64     @!in;
has int32     $.rank;
has int32     @.dims;
has int32     $.direction;
has int32     @.kind;
has uint32    $.dim;
has uint32    $.flag;
has int32     $.ikind;
has Bool      $.adv     is rw = False;
has int32     $.howmany is rw;
has int32     $.istride is rw;
has int32     $.ostride is rw;
has int32     $.idist   is rw;
has int32     $.odist   is rw;
has int32     @.inembed is rw;
has int32     @.onembed is rw;
has Int       $.thread;
has fftw_plan $!plan;

# Shaped Array
multi method new(:@data! where @data ~~ Array && @data.shape[0] ~~ UInt,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!,
                 UInt :$dim?,
                 Int  :$thread? = NONE,
                 Int  :$nthreads? = 1)
{
  # .Array flattens a shaped array since Rakudo 2018.09
  die 'This module needs at least Rakudo v2018.09 in order to use shaped arrays'
    if $*RAKU.compiler.version < v2018.09;
  self.bless(:data(@data.Array),
             :direction($direction),
             :dims(@data.shape),
             :flag($flag),
             :kind($kind),
             :dim($dim),
             :thread($thread),
             :nthreads($nthreads));
}

# Array of arrays
multi method new(:@data! where @data ~~ Array && @data[0] ~~ Array,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!,
                 UInt :$dim?,
                 Int  :$thread? = NONE,
                 Int  :$nthreads? = 1)
{
  fail X::Libfftw3.new: errno => NO-DIMS, error => 'Array of arrays: you must specify the dims array'
    if @dims.elems == 0;
  self.bless(:data(do { gather @data.deepmap(*.take) }),
             :direction($direction)
             :dims(@dims)
             :flag($flag)
             :kind($kind)
             :dim($dim),
             :thread($thread),
             :nthreads($nthreads));
}

# Plain array or Positional
multi method new(:@data! where @data !~~ Array || @data.shape[0] ~~ Whatever,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!,
                 UInt :$dim?,
                 Int  :$thread? = NONE,
                 Int  :$nthreads? = 1)
{
  self.bless(:data(@data),
             :direction($direction),
             :dims(@dims),
             :flag($flag),
             :kind($kind),
             :dim($dim),
             :thread($thread),
             :nthreads($nthreads));
}

# Math::Matrix object
multi method new(:$data! where .^name eq 'Math::Matrix',
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!,
                 UInt :$dim?,
                 Int  :$thread? = NONE,
                 Int  :$nthreads? = 1)
{
  self.bless(:data($data.list-rows.flat.list),
             :direction($direction),
             :dims($data.size),
             :flag($flag),
             :kind($kind),
             :dim($dim),
             :thread($thread),
             :nthreads($nthreads));
}

submethod BUILD(:@data!,
                :@dims?,
                Int  :$!direction? = FFTW_FORWARD,
                Int  :$flag? = FFTW_ESTIMATE,
                :$kind!,
                UInt :$dim? where { not .defined or $_ ~~ 1..3 },
                Int  :$thread? where thread-type = NONE,
                Int  :$nthreads? = 1)
{
  if $kind !~~ fftw_r2r_kind {
    fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Invalid value for argument kind';
  }
  if $!direction !~~ FFTW_FORWARD|FFTW_BACKWARD {
    fail X::Libfftw3.new: errno => DIRECTION-ERROR, error => 'Wrong direction. Try FFTW_FORWARD or FFTW_BACKWARD';
  }
  # What kind of data type?
  given @data[0] {
    when Int | Rat | Num {
      @!in := CArray[num64].new: @data».Num;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Rat or Num';
    }
  }
  # Initialize @!dims and $!rank when @data is not shaped or when is not an array
  if @data !~~ Array || @data.shape[0] ~~ Whatever {
    with @dims[0] {
      @!dims := CArray[int32].new: @dims;
      $!rank  = @dims.elems;
    } else {
      @!dims := CArray[int32].new: @!in.elems;
      $!rank  = 1;
    }
  } elsif @data ~~ Array && @data.shape[0] ~~ UInt {
    @!dims := CArray[int32].new: @dims;
    $!rank  = @!dims.elems;
  }
  $!dim    = $dim if $dim.defined;
  $!flag   = $flag;
  $!ikind  = $kind;
  $!thread = $thread;
  given $thread {
    when THREAD {
      fftw_tinit_threads();
      fftw_tplan_with_nthreads($nthreads);
    }
    when OPENMP {
      fftw_oinit_threads();
      fftw_oplan_with_nthreads($nthreads);
    }
  }
}

submethod DESTROY
{
  given $!thread {
    when THREAD { fftw_tcleanup_threads() }
    when OPENMP { fftw_ocleanup_threads() }
    default     { fftw_cleanup }
  }
}

method advanced(Int $rank!, @dims!, Int $howmany!,
                @inembed!, Int $istride!, Int $idist!,
                @onembed!, Int $ostride!, Int $odist!)
{
  $!adv      = True;
  $!rank     = $rank;
  @!dims    := CArray[int32].new: @dims;
  $!howmany  = $howmany;
  $!istride  = $istride;
  $!ostride  = $ostride;
  $!idist    = $idist;
  $!odist    = $odist;
  @!inembed := CArray[int32].new: @inembed;
  @!onembed := CArray[int32].new: @onembed;
  self;
}

multi method plan(Int $flag, $kind, $adv where :!so --> Nil)
{
  @!kind  := CArray[int32].new: $kind xx $!rank;
  @!out   := CArray[num64].new: 0e0 xx @!in.list.elems;
  given $!dim {
    when 1  { $!plan = fftw_plan_r2r_1d(@!dims[0], @!in, @!out, @!kind[0], $flag) }
    when 2  { $!plan = fftw_plan_r2r_2d(@!dims[0], @!dims[1], @!in, @!out, @!kind[0], @!kind[1], $flag) }
    when 3  { $!plan = fftw_plan_r2r_3d(@!dims[0], @!dims[1], @!dims[2], @!in, @!out, @!kind[0], @!kind[1], @!kind[2], $flag) }
    default { $!plan = fftw_plan_r2r($!rank, @!dims, @!in, @!out, @!kind, $flag) }
  }
}

multi method plan(Int $flag, $kind, $adv where :so --> Nil)
{
  @!kind := CArray[int32].new: $kind xx $!rank;
  @!out  := CArray[num64].new: 0e0 xx @!in.list.elems;
  $!plan  = fftw_plan_many_r2r(
    $!rank, @!dims, $!howmany,
    @!in,  @!inembed, $!istride, $!idist,
    @!out, @!onembed, $!ostride, $!odist,
    @!kind, $flag);
}

method execute(--> Positional)
{
  self.plan: $!flag, $!ikind, $!adv;
  fftw_execute($!plan);
  fftw_destroy_plan($!plan) with $!plan;
  given @!kind[0] {
    when FFTW_R2HC {
      return @!out.list;
    }
    when FFTW_HC2R {
      return @!out.list »/» [*] @!dims.list;
    }
    when FFTW_REDFT00 {
      if $!direction == FFTW_BACKWARD { # backward trasforms are not normalized
        return @!out.list »/» (2 * (([*] @!dims.list) - 1));
      } else {
        return @!out.list;
      }
    }
    when FFTW_RODFT00 {
      if $!direction == FFTW_BACKWARD {
        return @!out.list »/» (2 * (([*] @!dims.list) + 1));
      } else {
        return @!out.list;
      }
    }
    when FFTW_REDFT01|FFTW_REDFT10|FFTW_REDFT11|FFTW_RODFT01|FFTW_RODFT10|FFTW_RODFT11 {
      if $!direction == FFTW_BACKWARD {
        return @!out.list »/» (2 * [*] @!dims.list);
      } else {
        return @!out.list;
      }
    }
    default {
      fail X::Libfftw3.new: errno => KIND-ERROR, error => 'Wrong value for the @kind argument';
    }
  }
}

=begin pod

=head1 NAME

Math::FFT::Libfftw3::R2R - High-level bindings to libfftw3 Real-to-Complex transform

=head1 SYNOPSIS
=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_R2HC and FFTW_HC2R constants

my @in = (0, π/100 … 2*π)».sin;
put @in».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3::R2R $fft .= new: data => @in, kind => FFTW_R2HC;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, kind => FFTW_HC2R;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_R2HC and FFTW_HC2R constants

# direct 2D transform
my Math::FFT::Libfftw3::R2R $fft .= new: data => 1..18, dims => (6, 3), kind => FFTW_R2HC;
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6, 3), kind => FFTW_HC2R;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3::R2R> provides an OO interface to libfftw3 and allows you to perform Real-to-Real
Halfcomplex Fast Fourier Transforms.

The direct transform accepts an array of real numbers and outputs a half-complex array of real numbers.
The reverse transform accepts a half-complex array of real numbers and outputs an array of real numbers.


=head2 new(:@data!, :@dims?, Int :$flag? = FFTW_ESTIMATE, :$kind!, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)
=head2 new(:$data!, Int :$flag? = FFTW_ESTIMATE, :$kind!, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)

The first constructor accepts any Positional of type Int, Rat, Num (and IntStr, RatStr, NumStr);
it allows List of Ints, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument are B<@data> and B<$kind>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation>) and the array B<@dims>
must be passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<kind> argument, of type B<fftw_r2r_kind>, specifies what kind of trasform will be performed on the input data.
B<fftw_r2r_kind> constants are defined as an B<enum> in B<Math::FFT::Libfftw3::Constants>.
The values of the B<fftw_r2r_kind> enum are:

=item FFTW_R2HC
=item FFTW_HC2R
=item FFTW_DHT
=item FFTW_REDFT00
=item FFTW_REDFT01
=item FFTW_REDFT10
=item FFTW_REDFT11
=item FFTW_RODFT00
=item FFTW_RODFT01
=item FFTW_RODFT10
=item FFTW_RODFT11

The Half-Complex transform uses the symbol FFTW_R2HC for a Real to Half-Complex (direct) transform, while
the corresponding Half-Complex to Real (reverse) transform is specified by the symbol FFTW_HC2R.
The reverse transform of FFTW_R*DFT10 is FFTW_R*DFT01 and vice versa, of FFTW_R*DFT11 is FFTW_R*DFT11,
and of FFTW_R*DFT00 is FFTW_R*DFT00.

The B<$flag> parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to FFTW_ESTIMATE (see L<C Library Documentation>).

The B<$dim> parameter asks for an optimization for a specific matrix rank. The parameter is optional and if present
must be in the range 1..3.

The B<$thread> parameter specifies the kind of threaded operation one wants to get; this argument is optional and if
not specified is assumed as B<NONE>.
There are three possibile values:

=item NONE
=item THREAD
=item OPENMP

B<THREAD> will use specific POSIX thread library while B<OPENMP> will select an OpenMP library.

The B<$nthreads> specifies the number of threads to use; it defaults to 1.

The second constructor accepts a scalar: an object of type B<Math::Matrix> (if that module is installed, otherwise
it returns a B<Failure>), a B<$flag>, and a list of the kind of trasform one wants to be performed on each dimension;
the meaning of all the other parameters is the same as in the other constructor.

=head2 execute(--> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.

=head2 Attributes

Some of this class' attributes are readable:

=item @.out
=item $.rank
=item @.dims
=item $.direction
=item @.kind
=item $.dim (used when a specialized tranform has been requested)
=item $.flag (how to compute a plan)
=item $.adv (normal or advanced interface)
=item $.howmany (only for the advanced interface)
=item $.istride (only for the advanced interface)
=item $.ostride (only for the advanced interface)
=item $.idist   (only for the advanced interface)
=item $.odist   (only for the advanced interface)
=item @.inembed (only for the advanced interface)
=item @.onembed (only for the advanced interface)
=item $.thread  (only for the threaded model)

=head2 Wisdom interface

This interface allows to save and load a plan associated to a transform (There are some caveats. See L<C Library Documentation>).

=head3 plan-save(Str $filename --> True)

Saves the plan into a file. Returns B<True> if successful and a B<Failure> object otherwise.

=head3 plan-load(Str $filename --> True)

Loads the plan from a file. Returns B<True> if successful and a B<Failure> object otherwise.

=head2 Advanced interface

This interface allows to compose several transformations in one pass.
See L<C Library Documentation>.

=head3 advanced(Int $rank!, @dims!, Int $howmany!, @inembed!, Int $istride!, Int $idist!, @onembed!, Int $ostride!, Int $odist!)

This method activates the advanced interface. The meaning of the arguments are detailed in the
L<C Library Documentation>.

This method returns B<self>, so it can be concatenated to the B<.new()> method:

=begin code :lang<raku>
my $fft = Math::FFT::Libfftw3::R2R.new(data => 1..30)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
=end code


=head1 C Library Documentation

For more details on libfftw see L<http://www.fftw.org/>.
The manual is available here L<http://www.fftw.org/fftw3.pdf>

=head1 Prerequisites

This module requires the libfftw3 library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libfftw3-double3
=end code

The module looks for a library called libfftw3.so.

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::FFT::Libfftw3
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "raku -Ilib"
=end code

=head1 Notes

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Raku module.
If you need a pure Raku module, Math::FourierTransform works just fine.

This module needs Raku ≥ 2018.09 only if one wants to use shaped arrays as input data. An attempt to feed a shaped
array to the C<new> method using C«$*RAKU.compiler.version < v2018.09» results in an exception.

=head1 CAVEATS

There are some caveats regarding the way the various kind of R2R 1-dimensional transforms are computed and
their performances, and how the n-dimensional transforms are computed and why is probably a better idea to
use the R2C-C2R transform in case of multi-dimensional transforms.
Please refer to the documentation of the L<C Library Documentation>.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
