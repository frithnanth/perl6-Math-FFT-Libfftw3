#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

dies-ok { my $fft = Math::FFT::Libfftw3::R2R.new }, 'dies if no data passed';
throws-like
  { Math::FFT::Libfftw3::R2R.new: data => <a b c>, kind => FFTW_R2HC },
  X::Libfftw3,
  message => /Wrong ' ' type/,
  'fails with wrong data';
throws-like
  { Math::FFT::Libfftw3::R2R.new: data => 1..6, kind => FFTW_R2HC, direction => 12},
  X::Libfftw3,
  message => /Wrong ' ' direction/,
  'fails with wrong direction';
throws-like
  { Math::FFT::Libfftw3::R2R.new: data => 1..6, kind => 1 },
  X::Libfftw3,
  message => /Invalid ' ' value ' ' for ' ' argument ' ' kind/,
  'fails with wrong kind';

subtest {
  my Math::FFT::Libfftw3::R2R $fft .= new: data => 1..6, kind => FFTW_R2HC;
  isa-ok $fft, Math::FFT::Libfftw3::R2R, 'object type';
  cmp-ok $fft.rank,    '==', 1, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'r2r direct transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, direction => FFTW_BACKWARD, kind => FFTW_HC2R;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'r2r inverse transform';
  my Math::FFT::Libfftw3::R2R $fft2 .= new: data => 1..6, flag => FFTW_MEASURE, kind => FFTW_R2HC;
  my @out2 = $fft.execute;
  is-deeply @out2».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'using FFTW_MEASURE';
}, 'Range of Int - 1D transform with generic plan';

subtest {
  my Math::FFT::Libfftw3::R2R $fft .= new: data => 1..6, kind => FFTW_R2HC, dim => 1;
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'r2r direct transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, direction => FFTW_BACKWARD, kind => FFTW_HC2R, dim => 1;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'r2r inverse transform';
  my Math::FFT::Libfftw3::R2R $fft2 .= new: data => 1..6, flag => FFTW_MEASURE, kind => FFTW_R2HC, dim => 1;
  my @out2 = $fft.execute;
  is-deeply @out2».round(10⁻¹²),
    [21, -3, -3, -3, 1.732050807569, 5.196152422707]».round(10⁻¹²),
    'using FFTW_MEASURE';
  dies-ok { Math::FFT::Libfftw3::R2R.new: data => 1..6, kind => FFTW_R2HC, dim => 8 }, 'dies if dim not in 1..3';
}, 'Range of Int - 1D transform with specific 1D plan';

subtest {
  my Math::FFT::Libfftw3::R2R $fft .= new: data => 1..18, dims => (6, 3), kind => FFTW_R2HC;
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171, -9, 5.196152422707, -27, 0, 0, -27, 0, 0, -27, 0, 0,
     15.58845726812, 0, 0, 46.76537180436, 0, 0]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6,3), kind => FFTW_HC2R;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Range of Int - 2D transform';

subtest {
  my @array = [1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15], [16, 17, 18];
  throws-like
    { Math::FFT::Libfftw3::R2R.new: data => @array, kind => FFTW_HC2R },
    X::Libfftw3, message => /Array ' ' of ' ' arrays/,
    'fails if no dims present';
  my Math::FFT::Libfftw3::R2R $fft .= new: data => @array, dims => (6,3), kind => FFTW_R2HC;
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171, -9, 5.196152422707, -27, 0, 0, -27, 0, 0, -27, 0, 0,
     15.58845726812, 0, 0, 46.76537180436, 0, 0]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6,3), kind => FFTW_HC2R;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Array of arrays of Int - 2D transform';

subtest {
  my @array[6,3] = (1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12; 13, 14, 15; 16, 17, 18);
  my Math::FFT::Libfftw3::R2R $fft .= new: data => @array, kind => FFTW_R2HC;
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171, -9, 5.196152422707, -27, 0, 0, -27, 0, 0, -27, 0, 0,
     15.58845726812, 0, 0, 46.76537180436, 0, 0]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6,3), kind => FFTW_HC2R;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Shaped matrix of Int - 2D transform';

subtest {
  if (try require Math::Matrix) !=== Nil {
    my $matrix = Math::Matrix.new: [[1,2,3],[4,5,6],[7,8,9],[10,11,12],[13,14,15],[16,17,18]];
    my Math::FFT::Libfftw3::R2R $fft .= new: data => $matrix, kind => FFTW_R2HC;
    cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
    cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
    cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
    my @out;
    lives-ok { @out = $fft.execute }, 'execute transform';
    is-deeply @out».round(10⁻¹²),
    [171, -9, 5.196152422707, -27, 0, 0, -27, 0, 0, -27, 0, 0,
     15.58845726812, 0, 0, 46.76537180436, 0, 0]».round(10⁻¹²),
      'direct transform';
    my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6,3), kind => FFTW_HC2R;
    my @outr = $fftr.execute;
    is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
    throws-like
      { my $now = DateTime.new(now); Math::FFT::Libfftw3::R2R.new: data => $now },
      X::TypeCheck::Binding::Parameter,
      message => /Type ' ' check ' ' failed/,
      'fails with wrong data';
  } else {
    plan 1;
    skip-rest 'Math::Matrix not found';
  }
}, 'Math::Matrix';

subtest {
  my @in = (-π, -π + π/10 … π)».sin;
  my Math::FFT::Libfftw3::R2R $fft .= new: data => @in, kind => FFTW_RODFT00;
  isa-ok $fft, Math::FFT::Libfftw3::R2R, 'object type';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, direction => FFTW_BACKWARD, kind => FFTW_RODFT00;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), @in».round(10⁻¹²),  'r2r inverse transform';
}, '1D FFTW_RODFT00 transform';

subtest {
  my $fileout;
  ENTER {
    my $path = $*PROGRAM-NAME.subst(/ <-[/]>+$/, '');
    $fileout = $path ~ 'wisdom.dat';
    $fileout.IO.unlink if $fileout.IO.e;
  }
  LEAVE { $fileout.IO.unlink if $fileout.IO.e }
  my Math::FFT::Libfftw3::R2R $fft1 .= new: data => 1..6, flag => FFTW_MEASURE, kind => FFTW_R2HC;
  throws-like
    { $fft1.plan-save("nonexistent/$fileout") },
    X::Libfftw3, message => /Can\'t ' ' create ' ' file/,
    "fails if can't create output file";
  lives-ok { $fft1.plan-save($fileout) }, 'save plan to file';
  throws-like
    { $fft1.plan-load("nonexistent/$fileout") },
    X::Libfftw3, message => /Can\'t ' ' read ' ' file/,
    "fails if can't read input file";
  my Math::FFT::Libfftw3::R2R $fft2 .= new: data => 1..6, kind => FFTW_R2HC;
  lives-ok { $fft2.plan-load($fileout) }, 'read plan from file';
  lives-ok { $fft2.execute }, 'execute transform on saved plan';
}, 'Wisdom interface';

done-testing;
