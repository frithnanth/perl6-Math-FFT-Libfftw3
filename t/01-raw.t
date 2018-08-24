#!/usr/bin/env perl6
#
use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

my $p;
subtest {
  lives-ok { $p = fftw_malloc(1024) }, 'allocate memory';
  lives-ok { fftw_free($p) }, 'free memory';
}, 'memory management';
subtest {
  my $in = CArray[num64].allocate(12);
  $in[0..11] = (1..6)».Complex».reals.flat;
  my $out = CArray[num64].allocate(12);
  my fftw_plan $pland = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
            (21e0, 0e0, -3e0, 5.196152422706632e0, -3e0, 1.7320508075688772e0, -3e0, 0e0, -3e0, -1.7320508075688772e0, -3e0, -5.196152422706632e0)».round(10⁻¹²),
            'direct transform';
  my $back = CArray[num64].allocate(12);
  my fftw_plan $planr = fftw_plan_dft_1d(6, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply (($back.list »/» 6)[0, 2 … *])».round(10⁻¹²),
            (1.0, 2.0 … 6.0),
            'inverse transform';
}, 'c2c 1d transform';

done-testing;
