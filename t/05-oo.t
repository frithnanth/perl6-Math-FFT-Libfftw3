#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my Math::FFT::Libfftw3 $fft .= new: data => 1..6, :!pair;
  isa-ok $fft, Math::FFT::Libfftw3, 'object type';
  isa-ok $fft.in, 'NativeCall::Types::CArray[num64]', 'CArray data type';
  is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'input array';
  cmp-ok $fft.rank, '==', 1, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21e0 + 0e0i,
     -3e0 + 5.196152422706632e0i,
     -3e0 + 1.7320508075688772e0i,
     -3e0 + 0e0i,
     -3e0 + -1.7320508075688772e0i,
     -3e0 + -5.196152422706632e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3 $fftr .= new: data => @out, direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'inverse transform';
}, 'Range of Int - 1D transform';
subtest {
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1, 2 … 6);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Sequence of Int';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1..6).list;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of Int';
  }
  {
    my @data = 1..6;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Array of Int';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => 1/1..6/1;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Range of Rat';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1/1, 2/1 … 6/1);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Sequence of Rat';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1/1, 2/1, 3/1, 4/1, 5/1, 6/1);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of Rat';
  }
  {
    my @data = 1/1, 2/1, 3/1, 4/1, 5/1, 6/1;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Array of Rat';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => 1e0..6e0;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Range of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1e0, 2e0 … 6e0);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Sequence of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1e0..6e0).list;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of Num';
  }
  {
    my @data = 1e0..6e0;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Array of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1..6)».Complex;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of Complex';
  }
  {
    my @data = (1..6)».Complex;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'Array of Complex';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (<1>, <2>, <3>, <4>, <5>, <6>);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of IntStr';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (<1/1>, <2/1>, <3/1>, <4/1>, <5/1>, <6/1>);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of RatStr';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (<1e0>, <2e0>, <3e0>, <4e0>, <5e0>, <6e0>);
    is-deeply $fft.in.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'List of NumStr';
  }
}, 'Other types - 1D transform';
subtest {
  my Math::FFT::Libfftw3 $fft .= new: data => 1..18, dims => (6, 3);
  cmp-ok $fft.rank, '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
      -9e0 + -5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i,
       0e0 + 0e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3 $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0+0i, 2.0+0i … 18.0+0i], 'inverse transform';
}, 'Range of Int - 2D transform';
subtest {
  my @array[6,3] = (1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12; 13, 14, 15; 16, 17, 18);
  my Math::FFT::Libfftw3 $fft .= new: data => @array;
  cmp-ok $fft.rank, '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
      -9e0 + -5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i,
       0e0 + 0e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3 $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0+0i, 2.0+0i … 18.0+0i], 'inverse transform';
}, 'Shaped matrix of Int - 2D transform';
throws-like
  { Math::FFT::Libfftw3.new: data => <a b c> },
  X::Libfftw3,
  message => /Wrong ' ' type/,
  'fails with wrong data';

done-testing;
