## Math::FFT::Libfftw3

Math::FFT::Libfftw3 - An interface to libfftw3.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3)  | Travis CI |

## Example

```perl6
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
```

```perl6
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
```

For more examples see the `example` directory.

## Description

Math::FFT::Libfftw3 provides an interface to libfftw3 and allows you to perform Fast Fourier Transforms.

## Documentation

### Math::FFT::Libfftw3::C2C Complex-to-Complex transform

#### new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)
#### new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int  :$thread? = NONE, Int  :$nthreads? = 1)

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr);
it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is **@data**.
Multidimensional data are expressed in row-major order (see the [C Library Documentation](#c-library-documentation))
and the array **@dims** must be passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the **@dims** array, because the dimensions will be read
from the array itself.

The **$direction** parameter is used to specify a direct or backward transform; it defaults to `FFTW_FORWARD`.

The **$flag** parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to `FFTW_ESTIMATE` (see the [C Library Documentation](#c-library-documentation)).

The **$dim** parameter asks for an optimization for a specific matrix rank. The parameter is optional and if present
must be in the range 1..3.

The **$thread** parameter specifies the kind of threaded operation one wants to get; this argument is optional and if
not specified is assumed as **NONE**.
There are three possibile values:

* NONE
* THREAD
* OPENMP

**THREAD** will use specific POSIX thread library while **OPENMP** will select an OpenMP library.

The **$nthreads** specifies the number of threads to use; it defaults to 1.

The second constructor accepts a scalar: an object of type **Math::Matrix** (if that module is installed, otherwise
it returns a **Failure**); the meaning of all the other parameters is the same as in the other constructor.

#### execute(Int :$output? = OUT-COMPLEX --> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.
The parameter **$output** can be optionally used to specify how the array is to be returned:

* OUT-COMPLEX
* OUT-REIM
* OUT-NUM

The default (**OUT-COMPLEX**) is to return an array of Complex.
**OUT-REIM** makes the `execute` method return the native representation of the data: an array of couples of
real/imaginary values.
**OUT-NUM** makes the `execute` method return just the real part of the complex values.

#### Attributes

Some of this class' attributes are readable:

* @.out
* $.rank
* @.dims
* $.direction
* @.kind (available only in the R2R transform)
* $.dim (used when a specialized tranform has been requested)
* $.flag (how to compute a plan)
* $.adv (normal or advanced interface)
* $.howmany (only for the advanced interface)
* $.istride (only for the advanced interface)
* $.ostride (only for the advanced interface)
* $.idist   (only for the advanced interface)
* $.odist   (only for the advanced interface)
* @.inembed (only for the advanced interface)
* @.onembed (only for the advanced interface)
* $.thread  (only for the threaded model)

#### Wisdom interface

This interface allows to save and load a plan associated to a transform (There are some caveats.
See [C Library Documentation](#c-library-documentation)).

##### plan-save(Str $filename --> True)

Saves the plan into a file. Returns **True** if successful and a **Failure** object otherwise.

##### plan-load(Str $filename --> True)

Loads the plan From a file. Returns **True** if successful and a **Failure** object otherwise.

#### Advanced interface

This interface allows to compose several transformations in one pass.
See [C Library Documentation](#c-library-documentation).

##### advanced(Int $rank!, @dims!, Int $howmany!, @inembed!, Int $istride!, Int $idist!, @onembed!, Int $ostride!, Int $odist!)

This method activates the advanced interface. The meaning of the arguments are detailed in the
[C Library Documentation](#c-library-documentation).

This method returns `self`, so it can be concatenated to the `.new()` method:

```perl6
my $fft = Math::FFT::Libfftw3::C2C.new(data => (1..30).flat)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
```

### Math::FFT::Libfftw3::R2C Real-to-Complex transform

The interface for the R2C transform is slightly different.

In particular:

* in the `execute` method, when performing the reverse transform, the output array has only real values, so the `:$output` parameter is ignored.

See the `pod` documentation inside the module for further details.

### Math::FFT::Libfftw3::R2R Real-to-Real transform

This module implements several R2R transforms.
The major difference is that the constructor has a new `$kind` argument, which specifies the kind of trasform that
will be performed on the input data.

See the `pod` documentation inside the module for further details.

## C Library documentation

For more details on libfftw see [the FFTW home](http://www.fftw.org/).
The manual is available [here](http://www.fftw.org/fftw3.pdf).

## Prerequisites
This module requires the libfftw3 library to be installed. Please follow the instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libfftw3-double3
```

The module looks for a library called libfftw3.so.

## Installation

To install it using zef (a module management tool):

```
$ zef update
$ zef install Math::FFT::Libfftw3
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

## Notes

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl 6 module.
If you need a pure Perl 6 module, Math::FourierTransform works just fine.

This module needs Perl 6 ≥ 2018.09 only if one wants to use shaped arrays as input data. An attempt to feed a shaped
array to the `new` method using `$*PERL.compiler.version < v2018.09` results in an exception.

## TODO

There are some alternative interfaces to implement:

* The *guru* interface to apply the same plan to different data.
* The *distributed-memory* interface, for parallel systems supporting the MPI message-passing interface.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
