use v6;

unit class Math::FFT::Libfftw3:ver<0.0.1>:auth<cpan:FRITH>;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;

die 'This module needs at least v2018.09' if $*PERL.compiler.version < v2018.09;

constant TYPE-ERROR          is export = 1;

class X::Libfftw3 is Exception
{
  has Int $.errno;
  has Str $.error;
  method message { "Error {$!errno}: $!error" }
}

has num64     @.in;
has num64     @.out;
has int32     $.rank;
has int32     @.dims;
has int32     $!direction;
has fftw_plan $!plan;

submethod BUILD(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)
{
  if @data.WHAT ~~ Array && @data.shape[0].WHAT ~~ Int {
    @!dims := CArray[int32].new: @data.shape;
    $!rank  = @!dims.elems;
  }
  # .Array "flattens" a shaped array (since 2018.09) and does nothing to other types
  given @data.Array[0].WHAT {
    when Complex {
      @!in := CArray[num64].new: @data.Array.map(|*)».reals.List.flat;
    }
    when Int | Rat | Num {
      my @in2 = 0 xx (@data.Array.flat.elems * 2);
      for @data.Array.pairs -> $p {
        @in2[$p.key * 2] = $p.value;
      }
      @!in := CArray[num64].new: @in2».Num.flat;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Rat, Num or Complex';
    }
  }
  if @data.WHAT !~~ Array || @data.shape[0].WHAT ~~ Whatever {
    with @dims[0] {
      @!dims := CArray[int32].new: @dims;
      $!rank  = @dims.elems;
    } else {
      @!dims := CArray[int32].new: (@!in.elems / 2).Int;
      $!rank  = 1;
    }
  }
  # Invoking a plan with the FFTW_MEASURE flag destroys the input array; save its values.
  my @savein := CArray[num64].new: @!in.list;
  @!out      := CArray[num64].new: 0e0 xx @!in.elems;
  $!plan      = fftw_plan_dft($!rank, @!dims, @!in, @!out, $!direction, $flag);
  @!in       := CArray[num64].new: @savein.list;
}

submethod DESTROY
{
  fftw_destroy_plan($!plan) with $!plan;
  fftw_cleanup;
}

method execute(--> Positional)
{
  fftw_execute($!plan);
  if $!direction == FFTW_FORWARD {
    return @!out.map(-> $r, $i { Complex.new($r, $i) }).list;
  } else {
    # backward trasforms are not normalized
    return (@!out.list »/» [*] @!dims.list).map(-> $r, $i { Complex.new($r, $i) }).list;
  }
}

=begin pod

=head1 NAME

Math::FFT::Libfftw3 - High-level bindings to libfftw3

=head1 SYNOPSIS
=begin code

use v6;

use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants; # for the FFTW_BACKWARD constant

# direct 1D transform
my Math::FFT::Libfftw3 $fft .= new: data => 1..6;
my @out = $fft.execute;
put @out;
# reverse 1D transform
my Math::FFT::Libfftw3 $fftr .= new: data => @out, direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=begin code

use v6;

use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants; # for the FFTW_BACKWARD constant

# direct 2D transform
my Math::FFT::Libfftw3 $fft .= new: data => 1..18, dims => (6, 3);
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3 $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3> provides an OO interface to libfftw3.

=head2 new(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)

=head2 execute(--> Positional)

Executes the transform and returns the output array of values as

=head1 Documentation

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
$ prove -e "perl6 -Ilib"
=end code

=head1 Note

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl6 module.
If you need a pure Perl6 module, Math::FourierTransform works just fine.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
