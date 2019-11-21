#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

ok fftw_tinit_threads() == 1, 'thread initialization';

subtest {
  my $in = CArray[num64].new: (1..6)».Complex».reals.flat;
  my $out = CArray[num64].allocate(12);
  lives-ok { fftw_tplan_with_nthreads(3) }, 'number of threads';
  my fftw_plan $pland = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (21e0, 0e0,
     -3e0, 5.196152422706632e0,
     -3e0, 1.7320508075688772e0,
     -3e0, 0e0,
     -3e0, -1.7320508075688772e0,
     -3e0, -5.196152422706632e0)».round(10⁻¹²),
    'direct transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
  my $back = CArray[num64].allocate(12);
  my fftw_plan $planr = fftw_plan_dft_1d(6, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 6)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 6.0),
    'inverse transform';
  fftw_destroy_plan($planr);
  my fftw_plan $planip = fftw_plan_dft_1d(6, $in, $in, FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute($planip);
  is-deeply $in.list».round(10⁻¹²),
    (21e0, 0e0,
     -3e0, 5.196152422706632e0,
     -3e0, 1.7320508075688772e0,
     -3e0, 0e0,
     -3e0, -1.7320508075688772e0,
     -3e0, -5.196152422706632e0)».round(10⁻¹²),
    'direct transform in place';
  fftw_destroy_plan($planip);
}, 'threaded c2c 1d transform';

lives-ok { fftw_tcleanup_threads }, 'cleanup';

done-testing;
