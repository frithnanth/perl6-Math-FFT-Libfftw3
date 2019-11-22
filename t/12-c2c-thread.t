#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my Math::FFT::Libfftw3::C2C $fft1 .= new: data => 1..6, thread => THREAD, nthreads => 3;
  isa-ok $fft1, Math::FFT::Libfftw3::C2C, 'object type';
  my @out;
  lives-ok { @out = $fft1.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21e0 + 0e0i,
     -3e0 + 5.196152422706632e0i,
     -3e0 + 1.7320508075688772e0i,
     -3e0 + 0e0i,
     -3e0 + -1.7320508075688772e0i,
     -3e0 + -5.196152422706632e0i]».round(10⁻¹²),
    'direct transform - Complex output';
  my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, direction => FFTW_BACKWARD, thread => THREAD, nthreads => 3;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'inverse transform - Complex output';
}, 'threaded interface';

subtest {
  my Math::FFT::Libfftw3::C2C $fft1 .= new: data => 1..6, thread => OPENMP, nthreads => 3;
  isa-ok $fft1, Math::FFT::Libfftw3::C2C, 'object type';
  my @out;
  lives-ok { @out = $fft1.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21e0 + 0e0i,
     -3e0 + 5.196152422706632e0i,
     -3e0 + 1.7320508075688772e0i,
     -3e0 + 0e0i,
     -3e0 + -1.7320508075688772e0i,
     -3e0 + -5.196152422706632e0i]».round(10⁻¹²),
    'direct transform - Complex output';
  my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, direction => FFTW_BACKWARD, thread => THREAD, nthreads => 3;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'inverse transform - Complex output';
}, 'threaded interface: OpenMP';

done-testing;
