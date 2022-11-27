use v6;

unit class Math::FFT::Libfftw3:ver<0.3.5>:auth<zef:FRITH>;

use Math::FFT::Libfftw3::C2C;

=begin pod

=head1 NAME

Math::FFT::Libfftw3::C2C - High-level bindings to libfftw3 Complex-to-Complex transform

=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

my @in = (0, π/100 … 2*π)».sin;
put @in».Complex».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3::C2C $fft .= new: data => @in;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

# direct 2D transform
my Math::FFT::Libfftw3::C2C $fft .= new: data => 1..18, dims => (6, 3);
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3::C2C> provides an OO interface to libfftw3 and allows you to perform Complex-to-Complex
Fast Fourier Transforms.

=head2 new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)
=head2 new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr);
it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is B<@data>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation>) and the array B<@dims> must be
passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<$direction> parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

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
it returns a B<Failure>); the meaning of all the other parameters is the same as in the other constructor.

=head2 execute(Int :$output? = OUT-COMPLEX --> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.
The parameter B<$output> can be optionally used to specify how the array is to be returned:

=item OUT-COMPLEX
=item OUT-REIM
=item OUT-NUM

The default (B<OUT-COMPLEX>) is to return an array of Complex.
B<OUT-REIM> makes the C<execute> method return the native representation of the data: an array of couples of
real/imaginary values.
B<OUT-NUM> makes the C<execute> method return just the real part of the complex values.

=head2 Attributes

Some of this class' attributes are readable:

=item @.out
=item $.rank
=item @.dims
=item $.direction
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
my $fft = Math::FFT::Libfftw3.new(data => (1..30).flat)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
=end code

=head1 NAME

Math::FFT::Libfftw3::R2C - High-level bindings to libfftw3 Real-to-Complex transform

=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::R2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

my @in = (0, π/100 … 2*π)».sin;
put @in».Complex».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3::R2C $fft .= new: data => @in;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code :lang<raku>

use v6;

use Math::FFT::Libfftw3::R2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

# direct 2D transform
my Math::FFT::Libfftw3::R2C $fft .= new: data => 1..18, dims => (6, 3);
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3::R2C> provides an OO interface to libfftw3 and allows you to perform Real-to-Complex
Fast Fourier Transforms.

The direct transform accepts an array of real numbers and outputs a half-Hermitian array of complex numbers.
The reverse transform accepts a half-Hermitian array of complex numbers and outputs an array of real numbers.

=head2 new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)
=head2 new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr);
it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is B<@data>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation>) and the array B<@dims>
must be passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<$direction> parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

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
it returns a B<Failure>); the meaning of all the other parameters is the same as in the other constructor.

=head2 execute(Int :$output? = OUT-COMPLEX --> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.
The parameter B<$output> can be optionally used to specify how the array is to be returned:

=item OUT-COMPLEX
=item OUT-REIM
=item OUT-NUM

The default (B<OUT-COMPLEX>) is to return an array of Complex.
B<OUT-REIM> makes the C<execute> method return the native representation of the data: an array of couples of
real/imaginary values.
B<OUT-NUM> makes the C<execute> method return just the real part of the complex values.

When performing the reverse transform, the output array has only real values, so the C<:$output> parameter
is ignored.

=head2 Attributes

Some of this class' attributes are readable:

=item @.out
=item $.rank
=item @.dims
=item $.direction
=item $.dim (used when a specialized tranform has been requested)
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
my $fft = Math::FFT::Libfftw3::R2C.new(data => (1..30).flat)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
=end code

=head1 NAME

Math::FFT::Libfftw3::R2R - High-level bindings to libfftw3 Real-to-Complex transform

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

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
