## Math::FFT::Libfftw3

Math::FFT::Libfftw3 - An interface to libfftw3.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Math-FFT-Libfftw3)  | Travis CI |

## Example


For more examples see the `example` directory.

## Description

Math::FFT::Libfftw3 provides an interface to libfftw3 and allows you to perform Fast Fourier Transforms.

For more details on libfftw see L<http://www.fftw.org/>.

## Documentation


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

## Note

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl6 module.
If you need a pure Perl6 module, Math::FourierTransform works just fine.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
