#!/usr/bin/env perl6

use lib 'lib';
use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants;

# direct transform
my Math::FFT::Libfftw3 $fft .= new: data => 1..18, dims => (6, 3);
my @out = $fft.execute;
put @out;
# reverse transform
my Math::FFT::Libfftw3 $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);
