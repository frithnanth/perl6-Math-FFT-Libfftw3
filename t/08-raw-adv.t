#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my $rank = 2;
  my $n = CArray[int32].new: 5,6;
  my $howmany = 1;
  my $in = CArray[num64].new: (1..30)».Complex».reals.flat;
  my $out = CArray[num64].allocate(60);
  my $inembed := $n;
  my $onembed := $n;
  my $istride = 1;
  my $ostride = 1;
  my $idist = 0;
  my $odist = 0;
  my fftw_plan $pland = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $in,  $inembed, $istride, $idist,
    $out, $onembed, $ostride, $odist,
    FFTW_FORWARD, FFTW_ESTIMATE
  );
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (465e0, 0e0, -15e0, 25.980762113533e0, -15e0, 8.660254037844e0, -15e0, 0e0, -15e0, -8.660254037844e0, -15e0, -25.980762113533e0,
     -90e0, 123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, 29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
  my $back = CArray[num64].allocate(60);
  my fftw_plan $planr = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $out,  $onembed, $istride, $idist,
    $back, $inembed, $ostride, $odist,
    FFTW_BACKWARD, FFTW_ESTIMATE
  );
  fftw_execute($planr);
  is-deeply ($back.list »/» 30)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 30.0),
    'inverse transform';
  fftw_destroy_plan($planr);
  my fftw_plan $planip = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $in, $inembed, $istride, $idist,
    $in, $inembed, $ostride, $odist,
    FFTW_FORWARD, FFTW_ESTIMATE
  );
  fftw_execute($planip);
  is-deeply $in.list».round(10⁻¹²),
    (465e0, 0e0, -15e0, 25.980762113533e0, -15e0, 8.660254037844e0, -15e0, 0e0, -15e0, -8.660254037844e0, -15e0, -25.980762113533e0,
     -90e0, 123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, 29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform in place';
  fftw_destroy_plan($planip);
}, 'c2c advanced transform - one array contiguous in memory';

subtest {
  my $rank = 2;
  my $n = CArray[int32].new: 5,6;
  my $howmany = 3;
  my $in = CArray[num64].new: (((1..30)».Complex».reals.flat) xx 3).flat;
  my $out = CArray[num64].allocate(180);
  my $inembed := $n;
  my $onembed := $n;
  my $istride = 1;
  my $ostride = 1;
  my $idist = 30;
  my $odist = 30;
  my fftw_plan $pland = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $in,  $inembed, $istride, $idist,
    $out, $onembed, $ostride, $odist,
    FFTW_FORWARD, FFTW_ESTIMATE
  );
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (465e0, 0e0, -15e0, 25.980762113533e0, -15e0, 8.660254037844e0, -15e0, 0e0, -15e0, -8.660254037844e0, -15e0, -25.980762113533e0,
     -90e0, 123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, 29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     465e0, 0e0, -15e0, 25.980762113533e0, -15e0, 8.660254037844e0, -15e0, 0e0, -15e0, -8.660254037844e0, -15e0, -25.980762113533e0,
     -90e0, 123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, 29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     465e0, 0e0, -15e0, 25.980762113533e0, -15e0, 8.660254037844e0, -15e0, 0e0, -15e0, -8.660254037844e0, -15e0, -25.980762113533e0,
     -90e0, 123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, 29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -29.242772660962e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -90e0, -123.874372842406e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
   fftw_destroy_plan($pland);
  my $back = CArray[num64].allocate(180);
  my fftw_plan $planr = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $out,  $onembed, $ostride, $odist,
    $back, $inembed, $istride, $idist,
    FFTW_BACKWARD, FFTW_ESTIMATE
  );
  fftw_execute($planr);
  is-deeply ($back.list »/» 30)[0, 2 … *]».round(10⁻¹²),
    ((1.0, 2.0 … 30.0) xx 3).flat,
    'inverse transform';
  fftw_destroy_plan($planr);
}, 'c2c advanced transform - three arrays contiguous in memory';

subtest {
  my $rank = 1;
  my $n = CArray[int32].new: 10;
  my $howmany = 3;
  my $in = CArray[num64].new: (1..30)».Complex».reals.flat;
  my $out = CArray[num64].allocate(60);
  my $inembed := $n;
  my $onembed := $n;
  my $istride = 3;  # distance between two elements in the same column
  my $ostride = 3;
  my $idist = 1;
  my $odist = 1;
  my fftw_plan $pland = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $in,  $inembed, $istride, $idist,
    $out, $onembed, $ostride, $odist,
    FFTW_FORWARD, FFTW_ESTIMATE
  );
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (145e0, 0e0, 155e0, 0e0, 165e0, 0e0,
     -15e0, 46.165253057629e0, -15e0, 46.165253057629e0, -15e0, 46.165253057629e0,
     -15e0, 20.645728807068e0, -15e0, 20.645728807068e0, -15e0, 20.645728807068e0,
     -15e0, 10.89813792008e0, -15e0, 10.89813792008e0, -15e0, 10.89813792008e0,
     -15e0, 4.873795443494e0, -15e0, 4.873795443494e0, -15e0, 4.873795443494e0,
     -15e0, 0e0, -15e0, 0e0, -15e0, 0e0,
     -15e0, -4.873795443494e0, -15e0, -4.873795443494e0, -15e0, -4.873795443494e0,
     -15e0, -10.89813792008e0, -15e0, -10.89813792008e0, -15e0, -10.89813792008e0,
     -15e0, -20.645728807068e0, -15e0, -20.645728807068e0, -15e0, -20.645728807068e0,
     -15e0, -46.165253057629e0, -15e0, -46.165253057629e0, -15e0, -46.165253057629e0)».round(10⁻¹²),
    'direct transform';
  fftw_destroy_plan($pland);
  my $back = CArray[num64].allocate(60);
  my fftw_plan $planr = fftw_plan_many_dft(
    $rank, $n, $howmany,
    $out,  $onembed, $ostride, $odist,
    $back, $inembed, $istride, $idist,
    FFTW_BACKWARD, FFTW_ESTIMATE
  );
  fftw_execute($planr);
  is-deeply ($back.list »/» 10)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 30.0),
    'inverse transform';
  fftw_destroy_plan($planr);
}, 'c2c advanced transform - trasform each column of a 2d 10x3 array';

subtest {
  my $rank = 1;
  my $n = CArray[int32].new: 10;
  my $howmany = 3;
  my $in = CArray[num64].new: (1e0, 2e0 … 30e0);
  my $out = CArray[num64].allocate(45);
  my $inembed := $n;
  my $onembed := $n;
  my $istride = 3;  # distance between two elements in the same column
  my $ostride = 3;
  my $idist = 1;
  my $odist = 1;
  my fftw_plan $pland = fftw_plan_many_dft_r2c(
    $rank, $n, $howmany,
    $in,  $inembed, $istride, $idist,
    $out, $onembed, $ostride, $odist,
    FFTW_ESTIMATE
  );
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (145.0, 0.0, 155.0, 0.0, 165.0, 0.0, -15.0, 46.165253057629, -15.0, 46.165253057629, -15.0,
     46.165253057629, -15.0, 20.645728807068, -15.0, 20.645728807068, -15.0, 20.645728807068,
     -15.0, 10.89813792008, -15.0, 10.89813792008, -15.0, 10.89813792008, -15.0, 4.873795443494,
     -15.0, 4.873795443494, -15.0, 4.873795443494, -15.0, 0.0, -15.0, 0.0, -15.0, 0.0, 0.0, 0.0,
     0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)».round(10⁻¹²),
    'direct transform';
  fftw_destroy_plan($pland);
  my $back = CArray[num64].allocate(30);
  my fftw_plan $planr = fftw_plan_many_dft_c2r(
    $rank, $n, $howmany,
    $out,  $onembed, $ostride, $odist,
    $back, $inembed, $istride, $idist,
    FFTW_ESTIMATE
  );
  fftw_execute($planr);
  is-deeply ($back.list »/» 10)[^30]».round(10⁻¹²),
    (1.0, 2.0 … 30.0),
    'inverse transform';
  fftw_destroy_plan($planr);
}, 'r2c & c2r advanced transform - trasform each column of a 2d 10x3 array';

subtest {
  my $rank = 2;
  my $n = CArray[int32].new: 5,6;
  my $howmany = 1;
  my $in = CArray[num64].new: (1e0, 2e0 … 30e0);
  my $out = CArray[num64].allocate(30);
  my $inembed := $n;
  my $onembed := $n;
  my $istride = 1;
  my $ostride = 1;
  my $idist = 0;
  my $odist = 0;
  my $kind = CArray[int32].new: FFTW_REDFT00, FFTW_REDFT00;
  my fftw_plan $pland = fftw_plan_many_r2r(
    $rank, $n, $howmany,
    $in,  $inembed, $istride, $idist,
    $out, $onembed, $ostride, $odist,
    $kind, FFTW_ESTIMATE
  );
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (1240e0, -83.777087639997e0, 0e0, -12.222912360003e0, 0e0, -8e0,
     -409.705627484771e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -70.294372515229e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
  fftw_destroy_plan($pland);
  my $back = CArray[num64].allocate(30);
  my fftw_plan $planr = fftw_plan_many_r2r(
    $rank, $n, $howmany,
    $out,  $onembed, $istride, $idist,
    $back, $inembed, $ostride, $odist,
    $kind, FFTW_ESTIMATE
  );
  fftw_execute($planr);
  is-deeply ($back.list »/» 80)[^30]».round(10⁻¹²), # n₁ = 5, n₂ = 6; 2(n₁ - 1) × 2(n₂ -1) = 8 * 10 = 80
    (1.0, 2.0 … 30.0),
    'inverse transform';
  fftw_destroy_plan($planr);
}, 'r2r advanced transform';

lives-ok { fftw_cleanup }, 'cleanup';

done-testing;
