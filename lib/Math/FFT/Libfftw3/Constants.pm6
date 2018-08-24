use v6;

unit module Math::FFT::Libfftw3::Constants:ver<0.0.1>;

constant FFTW_FORWARD  is export = -1;
constant FFTW_BACKWARD is export =  1;

constant FFTW_MEASURE         is export =  0;
constant FFTW_DESTROY_INPUT   is export =  1 +<  0;
constant FFTW_UNALIGNED       is export =  1 +<  1;
constant FFTW_CONSERVE_MEMORY is export =  1 +<  2;
constant FFTW_EXHAUSTIVE      is export =  1 +<  3;
constant FFTW_PRESERVE_INPUT  is export =  1 +<  4;
constant FFTW_PATIENT         is export =  1 +<  5;
constant FFTW_ESTIMATE        is export =  1 +<  6;
constant FFTW_WISDOM_ONLY     is export =  1 +< 21;

