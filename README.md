[![Actions Status](https://github.com/frithnanth/perl6-Math-FFT-Libfftw3/workflows/test/badge.svg)](https://github.com/frithnanth/perl6-Math-FFT-Libfftw3/actions)

NAME
====

Math::FFT::Libfftw3::C2C - High-level bindings to libfftw3 Complex-to-Complex transform

```raku
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

```raku
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

DESCRIPTION
===========

**Math::FFT::Libfftw3::C2C** provides an OO interface to libfftw3 and allows you to perform Complex-to-Complex Fast Fourier Transforms.

new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
------------------------------------------------------------------------------------------------------------------------------------------

new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
---------------------------------------------------------------------------------------------------------------------------------

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr); it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is **@data**. Multidimensional data are expressed in row-major order (see [C Library Documentation](C Library Documentation)) and the array **@dims** must be passed to the constructor, or the data will be interpreted as a 1D array. If one uses a shaped array, there's no need to pass the **@dims** array, because the dimensions will be read from the array itself.

The **$direction** parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

The **$flag** parameter specifies the way the underlying library has to analyze the data in order to create a plan for the transform; it defaults to FFTW_ESTIMATE (see [C Library Documentation](C Library Documentation)).

The **$dim** parameter asks for an optimization for a specific matrix rank. The parameter is optional and if present must be in the range 1..3.

The **$thread** parameter specifies the kind of threaded operation one wants to get; this argument is optional and if not specified is assumed as **NONE**. There are three possibile values:

  * NONE

  * THREAD

  * OPENMP

**THREAD** will use specific POSIX thread library while **OPENMP** will select an OpenMP library.

The **$nthreads** specifies the number of threads to use; it defaults to 1.

The second constructor accepts a scalar: an object of type **Math::Matrix** (if that module is installed, otherwise it returns a **Failure**); the meaning of all the other parameters is the same as in the other constructor.

execute(Int :$output? = OUT-COMPLEX --> Positional)
---------------------------------------------------

Executes the transform and returns the output array of values as a normalized row-major array. The parameter **$output** can be optionally used to specify how the array is to be returned:

  * OUT-COMPLEX

  * OUT-REIM

  * OUT-NUM

The default (**OUT-COMPLEX**) is to return an array of Complex. **OUT-REIM** makes the `execute` method return the native representation of the data: an array of couples of real/imaginary values. **OUT-NUM** makes the `execute` method return just the real part of the complex values.

Attributes
----------

Some of this class' attributes are readable:

  * @.out

  * $.rank

  * @.dims

  * $.direction

  * $.dim (used when a specialized tranform has been requested)

  * $.flag (how to compute a plan)

  * $.adv (normal or advanced interface)

  * $.howmany (only for the advanced interface)

  * $.istride (only for the advanced interface)

  * $.ostride (only for the advanced interface)

  * $.idist (only for the advanced interface)

  * $.odist (only for the advanced interface)

  * @.inembed (only for the advanced interface)

  * @.onembed (only for the advanced interface)

  * $.thread (only for the threaded model)

Wisdom interface
----------------

This interface allows to save and load a plan associated to a transform (There are some caveats. See [C Library Documentation](C Library Documentation)).

### plan-save(Str $filename --> True)

Saves the plan into a file. Returns **True** if successful and a **Failure** object otherwise.

### plan-load(Str $filename --> True)

Loads the plan from a file. Returns **True** if successful and a **Failure** object otherwise.

Advanced interface
------------------

This interface allows to compose several transformations in one pass. See [C Library Documentation](C Library Documentation).

### advanced(Int $rank!, @dims!, Int $howmany!, @inembed!, Int $istride!, Int $idist!, @onembed!, Int $ostride!, Int $odist!)

This method activates the advanced interface. The meaning of the arguments are detailed in the [C Library Documentation](C Library Documentation).

This method returns **self**, so it can be concatenated to the **.new()** method:

```raku
my $fft = Math::FFT::Libfftw3.new(data => (1..30).flat)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
```

NAME
====

Math::FFT::Libfftw3::R2C - High-level bindings to libfftw3 Real-to-Complex transform

```raku
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
```

```raku
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
```

DESCRIPTION
===========

**Math::FFT::Libfftw3::R2C** provides an OO interface to libfftw3 and allows you to perform Real-to-Complex Fast Fourier Transforms.

The direct transform accepts an array of real numbers and outputs a half-Hermitian array of complex numbers. The reverse transform accepts a half-Hermitian array of complex numbers and outputs an array of real numbers.

new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
------------------------------------------------------------------------------------------------------------------------------------------

new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
---------------------------------------------------------------------------------------------------------------------------------

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr); it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is **@data**. Multidimensional data are expressed in row-major order (see [C Library Documentation](C Library Documentation)) and the array **@dims** must be passed to the constructor, or the data will be interpreted as a 1D array. If one uses a shaped array, there's no need to pass the **@dims** array, because the dimensions will be read from the array itself.

The **$direction** parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

The **$flag** parameter specifies the way the underlying library has to analyze the data in order to create a plan for the transform; it defaults to FFTW_ESTIMATE (see [C Library Documentation](C Library Documentation)).

The **$dim** parameter asks for an optimization for a specific matrix rank. The parameter is optional and if present must be in the range 1..3.

The **$thread** parameter specifies the kind of threaded operation one wants to get; this argument is optional and if not specified is assumed as **NONE**. There are three possibile values:

  * NONE

  * THREAD

  * OPENMP

**THREAD** will use specific POSIX thread library while **OPENMP** will select an OpenMP library.

The **$nthreads** specifies the number of threads to use; it defaults to 1.

The second constructor accepts a scalar: an object of type **Math::Matrix** (if that module is installed, otherwise it returns a **Failure**); the meaning of all the other parameters is the same as in the other constructor.

execute(Int :$output? = OUT-COMPLEX --> Positional)
---------------------------------------------------

Executes the transform and returns the output array of values as a normalized row-major array. The parameter **$output** can be optionally used to specify how the array is to be returned:

  * OUT-COMPLEX

  * OUT-REIM

  * OUT-NUM

The default (**OUT-COMPLEX**) is to return an array of Complex. **OUT-REIM** makes the `execute` method return the native representation of the data: an array of couples of real/imaginary values. **OUT-NUM** makes the `execute` method return just the real part of the complex values.

When performing the reverse transform, the output array has only real values, so the `:$output` parameter is ignored.

Attributes
----------

Some of this class' attributes are readable:

  * @.out

  * $.rank

  * @.dims

  * $.direction

  * $.dim (used when a specialized tranform has been requested)

  * $.adv (normal or advanced interface)

  * $.howmany (only for the advanced interface)

  * $.istride (only for the advanced interface)

  * $.ostride (only for the advanced interface)

  * $.idist (only for the advanced interface)

  * $.odist (only for the advanced interface)

  * @.inembed (only for the advanced interface)

  * @.onembed (only for the advanced interface)

  * $.thread (only for the threaded model)

Wisdom interface
----------------

This interface allows to save and load a plan associated to a transform (There are some caveats. See [C Library Documentation](C Library Documentation)).

### plan-save(Str $filename --> True)

Saves the plan into a file. Returns **True** if successful and a **Failure** object otherwise.

### plan-load(Str $filename --> True)

Loads the plan from a file. Returns **True** if successful and a **Failure** object otherwise.

Advanced interface
------------------

This interface allows to compose several transformations in one pass. See [C Library Documentation](C Library Documentation).

### advanced(Int $rank!, @dims!, Int $howmany!, @inembed!, Int $istride!, Int $idist!, @onembed!, Int $ostride!, Int $odist!)

This method activates the advanced interface. The meaning of the arguments are detailed in the [C Library Documentation](C Library Documentation).

This method returns **self**, so it can be concatenated to the **.new()** method:

```raku
my $fft = Math::FFT::Libfftw3::R2C.new(data => (1..30).flat)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
```

NAME
====

Math::FFT::Libfftw3::R2R - High-level bindings to libfftw3 Real-to-Complex transform

```raku
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
```

```raku
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
```

DESCRIPTION
===========

**Math::FFT::Libfftw3::R2R** provides an OO interface to libfftw3 and allows you to perform Real-to-Real Halfcomplex Fast Fourier Transforms.

The direct transform accepts an array of real numbers and outputs a half-complex array of real numbers. The reverse transform accepts a half-complex array of real numbers and outputs an array of real numbers.

new(:@data!, :@dims?, Int :$flag? = FFTW_ESTIMATE, :$kind!, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
------------------------------------------------------------------------------------------------------------------

new(:$data!, Int :$flag? = FFTW_ESTIMATE, :$kind!, Int :$dim?, Int :$thread? = NONE, Int :$nthreads? = 1)
---------------------------------------------------------------------------------------------------------

The first constructor accepts any Positional of type Int, Rat, Num (and IntStr, RatStr, NumStr); it allows List of Ints, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument are **@data** and **$kind**. Multidimensional data are expressed in row-major order (see [C Library Documentation](C Library Documentation)) and the array **@dims** must be passed to the constructor, or the data will be interpreted as a 1D array. If one uses a shaped array, there's no need to pass the **@dims** array, because the dimensions will be read from the array itself.

The **kind** argument, of type **fftw_r2r_kind**, specifies what kind of trasform will be performed on the input data. **fftw_r2r_kind** constants are defined as an **enum** in **Math::FFT::Libfftw3::Constants**. The values of the **fftw_r2r_kind** enum are:

  * FFTW_R2HC

  * FFTW_HC2R

  * FFTW_DHT

  * FFTW_REDFT00

  * FFTW_REDFT01

  * FFTW_REDFT10

  * FFTW_REDFT11

  * FFTW_RODFT00

  * FFTW_RODFT01

  * FFTW_RODFT10

  * FFTW_RODFT11

The Half-Complex transform uses the symbol FFTW_R2HC for a Real to Half-Complex (direct) transform, while the corresponding Half-Complex to Real (reverse) transform is specified by the symbol FFTW_HC2R. The reverse transform of FFTW_R*DFT10 is FFTW_R*DFT01 and vice versa, of FFTW_R*DFT11 is FFTW_R*DFT11, and of FFTW_R*DFT00 is FFTW_R*DFT00.

The **$flag** parameter specifies the way the underlying library has to analyze the data in order to create a plan for the transform; it defaults to FFTW_ESTIMATE (see [C Library Documentation](C Library Documentation)).

The **$dim** parameter asks for an optimization for a specific matrix rank. The parameter is optional and if present must be in the range 1..3.

The **$thread** parameter specifies the kind of threaded operation one wants to get; this argument is optional and if not specified is assumed as **NONE**. There are three possibile values:

  * NONE

  * THREAD

  * OPENMP

**THREAD** will use specific POSIX thread library while **OPENMP** will select an OpenMP library.

The **$nthreads** specifies the number of threads to use; it defaults to 1.

The second constructor accepts a scalar: an object of type **Math::Matrix** (if that module is installed, otherwise it returns a **Failure**), a **$flag**, and a list of the kind of trasform one wants to be performed on each dimension; the meaning of all the other parameters is the same as in the other constructor.

execute(--> Positional)
-----------------------

Executes the transform and returns the output array of values as a normalized row-major array.

Attributes
----------

Some of this class' attributes are readable:

  * @.out

  * $.rank

  * @.dims

  * $.direction

  * @.kind

  * $.dim (used when a specialized tranform has been requested)

  * $.flag (how to compute a plan)

  * $.adv (normal or advanced interface)

  * $.howmany (only for the advanced interface)

  * $.istride (only for the advanced interface)

  * $.ostride (only for the advanced interface)

  * $.idist (only for the advanced interface)

  * $.odist (only for the advanced interface)

  * @.inembed (only for the advanced interface)

  * @.onembed (only for the advanced interface)

  * $.thread (only for the threaded model)

Wisdom interface
----------------

This interface allows to save and load a plan associated to a transform (There are some caveats. See [C Library Documentation](C Library Documentation)).

### plan-save(Str $filename --> True)

Saves the plan into a file. Returns **True** if successful and a **Failure** object otherwise.

### plan-load(Str $filename --> True)

Loads the plan from a file. Returns **True** if successful and a **Failure** object otherwise.

Advanced interface
------------------

This interface allows to compose several transformations in one pass. See [C Library Documentation](C Library Documentation).

### advanced(Int $rank!, @dims!, Int $howmany!, @inembed!, Int $istride!, Int $idist!, @onembed!, Int $ostride!, Int $odist!)

This method activates the advanced interface. The meaning of the arguments are detailed in the [C Library Documentation](C Library Documentation).

This method returns **self**, so it can be concatenated to the **.new()** method:

```raku
my $fft = Math::FFT::Libfftw3::R2R.new(data => 1..30)
                                  .advanced: $rank, @dims, $howmany,
                                             @inembed, $istride, $idist,
                                             @onembed, $ostride, $odist;
```

C Library Documentation
=======================

For more details on libfftw see [http://www.fftw.org/](http://www.fftw.org/). The manual is available here [http://www.fftw.org/fftw3.pdf](http://www.fftw.org/fftw3.pdf)

Prerequisites
=============

This module requires the libfftw3 library to be installed. Please follow the instructions below based on your platform:

Debian Linux
------------

    sudo apt-get install libfftw3-double3

The module looks for a library called libfftw3.so.

Installation
============

To install it using zef (a module management tool):

    $ zef install Math::FFT::Libfftw3

Testing
=======

To run the tests:

    $ prove -e "raku -Ilib"

Notes
=====

Math::FFT::Libfftw3 relies on a C library which might not be present in one's installation, so it's not a substitute for a pure Raku module. If you need a pure Raku module, Math::FourierTransform works just fine.

This module needs Raku ≥ 2018.09 only if one wants to use shaped arrays as input data. An attempt to feed a shaped array to the `new` method using `$*RAKU.compiler.version < v2018.09` results in an exception.

Author
======

Fernando Santagata

License
=======

The Artistic License 2.0

