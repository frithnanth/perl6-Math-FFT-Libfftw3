#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my Math::FFT::Libfftw3::R2R $fft1 .= new: data => 1..6, kind => FFTW_R2HC, thread => THREAD, nthreads => 3;
  isa-ok $fft1, Math::FFT::Libfftw3::R2R, 'object type';
  my @out;
  lives-ok { @out = $fft1.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'direct transform - Complex output';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, direction => FFTW_BACKWARD, kind => FFTW_HC2R, thread => OPENMP, nthreads => 3;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'r2r inverse transform';
}, 'threaded interface';

subtest {
  my Math::FFT::Libfftw3::R2R $fft1 .= new: data => 1..6, kind => FFTW_R2HC, thread => OPENMP, nthreads => 3;
  isa-ok $fft1, Math::FFT::Libfftw3::R2R, 'object type';
  my @out;
  lives-ok { @out = $fft1.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'direct transform - Complex output';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, direction => FFTW_BACKWARD, kind => FFTW_HC2R, thread => OPENMP, nthreads => 3;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'r2r inverse transform';
}, 'threaded interface: OpenMP';

done-testing;
