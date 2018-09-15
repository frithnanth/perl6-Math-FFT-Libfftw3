#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use Math::FFT::Libfftw3;
use NativeCall;

subtest {
  {
    my Math::FFT::Libfftw3 $fft .= new: data => 1..6, :!pair;
    isa-ok $fft, Math::FFT::Libfftw3, 'object type';
    isa-ok $fft.carrdata, NativeCall::Types::CArray[num64], 'CArray data type';
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Range of Int';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1, 2 … 6);
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Sequence of Int';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1..6).list;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from List of Int';
  }
  {
    my @data = 1..6;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Array of Int';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => 1e0..6e0;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Range of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1e0, 2e0 … 6e0);
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Sequence of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1e0..6e0).list;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from List of Num';
  }
  {
    my @data = 1e0..6e0;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Array of Num';
  }
  {
    my @data = 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0;
    my Math::FFT::Libfftw3 $fft .= new: data => @data, :pair;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from pairs of Int';
  }
  {
    my @data = 1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0;
    my Math::FFT::Libfftw3 $fft .= new: data => @data, :pair;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from pairs of Num';
  }
  {
    my Math::FFT::Libfftw3 $fft .= new: data => (1..6)».Complex;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from List of Complex';
  }
  {
    my @data = (1..6)».Complex;
    my Math::FFT::Libfftw3 $fft .= new: data => @data;
    is-deeply $fft.carrdata.list, (1e0, 0e0, 2e0, 0e0, 3e0, 0e0, 4e0, 0e0, 5e0, 0e0, 6e0, 0e0), 'from Array of Complex';
  }
  throws-like
    { Math::FFT::Libfftw3.new: data => <a b c> },
    X::Libfftw3,
    message => /Wrong ' ' type/,
    'fails with wrong data';
}, 'new';

done-testing;
