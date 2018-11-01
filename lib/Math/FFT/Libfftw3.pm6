use v6;

unit class Math::FFT::Libfftw3:ver<0.0.1>:auth<cpan:FRITH>;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;

constant TYPE-ERROR          is export = 1;
constant DIRECTION-ERROR     is export = 2;
constant NO-DIMS             is export = 3;

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
has int32     $.direction;
has fftw_plan $!plan;

submethod BUILD(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)
{
  # What kind of Positional?
  my @ndata;
  if @data ~~ Array && @data.shape[0] ~~ Int {              # shaped array
    die 'This module needs at least Rakudo v2018.09 in order to use shaped arrays'
      if $*PERL.compiler.version < v2018.09;
    @!dims := CArray[int32].new: @data.shape;
    $!rank  = @!dims.elems;
    @ndata := @data.Array; # .Array flattens a shaped array since Rakudo 2018.09
  } elsif @data ~~ Array && @data[0] ~~ Array {             # array of arrays
    fail X::Libfftw3.new: errno => NO-DIMS, error => 'Array of arrays: you must specify the dims array'
      if @dims.elems == 0;
    @ndata  = do gather @data.deepmap(*.take);
  } elsif @data !~~ Array || @data.shape[0] ~~ Whatever {   # plain array or Positional
    @ndata := @data;
  } else {
    fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Not a Positional';
  }
  # What data type?
  given @ndata[0] {
    when Complex {
      @!in := CArray[num64].new: @ndata.map(|*)».reals.List.flat;
    }
    when Int | Rat | Num {
      @!in := CArray[num64].new: (@ndata Z 0 xx @ndata.elems).flat».Num;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Rat, Num or Complex';
    }
  }
  # Initialize @!dims and $!rank when @data is not shaped or when is not an array
  if @data !~~ Array || @data.shape[0] ~~ Whatever {
    with @dims[0] {
      @!dims := CArray[int32].new: @dims;
      $!rank  = @dims.elems;
    } else {
      @!dims := CArray[int32].new: (@!in.elems / 2).Int;
      $!rank  = 1;
    }
  }
  self.plan: $flag;
}

submethod DESTROY
{
  fftw_destroy_plan($!plan) with $!plan;
  fftw_cleanup;
}

method plan($flag --> Nil)
{
  # Create a plan. The FFTW_MEASURE flag destroys the input array; save its values.
  my @savein := CArray[num64].new: @!in.list;
  @!out      := CArray[num64].new: 0e0 xx @!in.elems;
  $!plan      = fftw_plan_dft($!rank, @!dims, @!in, @!out, $!direction, $flag);
  @!in       := CArray[num64].new: @savein.list;
}

method execute(--> Positional)
{
  fftw_execute($!plan);
  given $!direction {
    when FFTW_FORWARD {
      return @!out.map(-> $r, $i { Complex.new($r, $i) }).list;
    }
    when FFTW_BACKWARD {
      # backward trasforms are not normalized
      return (@!out.list »/» [*] @!dims.list).map(-> $r, $i { Complex.new($r, $i) }).list;
    }
    default {
      fail X::Libfftw3.new: errno => DIRECTION-ERROR, error => 'Wrong direction. Try FFTW_FORWARD or FFTW_BACKWARD';
    }
  }
}

=begin pod

=head1 NAME

Math::FFT::Libfftw3 - High-level bindings to libfftw3

=head1 SYNOPSIS
=begin code

use v6;

use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

my @in = (0, π/100 … 2*π)».sin;
put @in».Complex».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3 $fft .= new: data => @in;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3 $fftr .= new: data => @out, direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code

use v6;

use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

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

B<Math::FFT::Libfftw3> provides an OO interface to libfftw3 and allows you to perform Fast Fourier Transforms.

=head2 new(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)

The constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr).
So it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is B<@data>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation|#clib>) and the array B<@dims> must be
passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<$direction> parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

The B<$flag> parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to FFTW_ESTIMATE (see L<#Documentation>).

=head2 execute(--> Positional)

Executes the transform and returns the output array of values as a normalized row-major array of Complex.

=head2 Attributes

Some of this class' attributes are readable:

=item @.in
=item @.out
=item $.rank
=item @.dims

Since their data type is native, there is an additional passage to get the values of the arrays:

=begin code

use Math::FFT::Libfftw3;

my $fft = Math::FFT::Libfftw3.new: data => 1..6;
say $fft.in.list;    # say $fft.in; doesn't work as one might expect

=end code

This program prints

=begin code

(1 0 2 0 3 0 4 0 5 0 6 0)

=end code

because the C library's representation of the Complex type is just a couple of real numbers.

=head1 L<C Library Documentation|#clib>

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

=head1 Notes

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl 6 module.
If you need a pure Perl 6 module, Math::FourierTransform works just fine.

This module need Perl 6 ≥ 2018.09 in order to use shaped arrays.

When using Math::Matrix, pass the object this way:

=begin code

use Math::Matrix;
use Math::FFT::Libfftw3;

my $matrix = Math::Matrix.new( [[1,2],[3,4]] );
my $fft = Math::FFT::Libfftw3.new: data => $matrix.list-rows.flat, dims => (2, 2);

=end code

Note that in this case the B<dims> parameter is mandatory, because Math::Matrix doesn't use shaped matrices yet.

=head1 TODO

A lot.

The underlying C library provides functions for trasnforming a complex input into a complex output: a c2c transform.
There are other possibilities: r2c and c2r transforms, and r2r transforms:

=item DFT con real input, complex-Hermitian halfcomplex output
=item DFT con real input, even/odd symmetry (discrete cosine/sine transform: DCT/DST)
=item DHT Discrete Hartley Transform

Besides:

=item There's a I<guru> interface to apply the same plan to different data.
=item There's a I<wisdom> interface to save and load the plan.
=item There's a I<multi-threaded> interface, which supports parallel one- and multi-dimensional transforms.
=item There's a I<distributed-memory> interface, for parallel systems supporting the MPI message-passing interface.

Future development might change the API or might provide different classes for each data type.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
