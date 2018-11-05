## Math::FFT::Libfftw3

Math::FFT::Libfftw3 - An interface to libfftw3.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3)  | Travis CI |

## Example

```perl6
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
```

```perl6
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
```

For more examples see the `example` directory.

## Description

Math::FFT::Libfftw3 provides an interface to libfftw3 and allows you to perform Fast Fourier Transforms.

## Documentation

#### new(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)
#### new(:$data!, :$!direction? = FFTW_FORWARD, :$flag? = FFTW_ESTIMATE)

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr);
it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is **@data**.
Multidimensional data are expressed in row-major order (see the [C Library Documentation](#clib))
and the array **@dims** must be passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the **@dims** array, because the dimensions will be read
from the array itself.

The **$direction** parameter is used to specify a direct or backward transform; it defaults to `FFTW_FORWARD`.

The **$flag** parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to `FFTW_ESTIMATE` (see the C Library Documentation).

The second constructor accepts a scalar: an object of type **Math::Matrix** (if that module is installed, otherwise
it returns a **Failure**), a **$direction**, and a **$flag**; the meaning of the last two parameters is the same as
in the other constructor.

#### execute(--> Positional)

Executes the transform and returns the output array of values as a normalized row-major array of Complex.

#### Attributes

Some of this class' attributes are readable:

* @.in
* @.out
* $.rank
* @.dims

Since their data type is native, there is an additional passage to get the values of the arrays:

```perl6

my $fft = Math::FFT::Libfftw3.new: data => 1..6;
say $fft.in.list;    # say $fft.in; doesn't work as one might expect

```

This program prints

```perl6

(1 0 2 0 3 0 4 0 5 0 6 0)

```

because the C library's representation of the Complex type is just a couple of real numbers.

**Math::FFT::Libfftw3** represents complex number this way to ease the communication with the C library.
If one needs a **Complex** or **Num** array, one has to convert it in some way.
For example:

```perl6

my $fft = Math::FFT::Libfftw3.new: data => 1..6;
say $fft.in.list;
say $fft.in.list.map: -> $re,$im { Complex.new: $re, $im };
say $fft.in.list[0,2 … *];

```

## [C Library documentation](#clib)

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

This module need Perl 6 ≥ 2018.09 in order to use shaped arrays.

## TODO

A lot.

The underlying C library provides functions for trasnforming a complex input into a complex output: a c2c transform.
There are other possibilities: r2c and c2r transforms, and r2r transforms:

* DFT con real input, complex-Hermitian halfcomplex output
* DFT con real input, even/odd symmetry (discrete cosine/sine transform: DCT/DST)
* DHT Discrete Hartley Transform

Besides:

* There's a *guru* interface to apply the same plan to different data.
* There's a *wisdom* interface to save and load the plan.
* There's a *multi-threaded* interface, which supports parallel one- and multi-dimensional transforms.
* There's a *distributed-memory* interface, for parallel systems supporting the MPI message-passing interface.

Future development might change the API or might provide different classes for each data type.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
