use v6;

constant TYPE-ERROR          is export = 1;
constant DIRECTION-ERROR     is export = 2;
constant NO-DIMS             is export = 3;
constant FILE-ERROR          is export = 4;

constant OUT-COMPLEX         is export = 0;
constant OUT-REIM            is export = 1;
constant OUT-NUM             is export = 2;

class X::Libfftw3 is Exception
{
  has Int $.errno;
  has Str $.error;
  method message { "Error {$!errno}: $!error" }
}

role FFTRole {
  use NativeCall;
  use Math::FFT::Libfftw3::Raw;

  has num64     @.out;
  has int32     $.rank;
  has int32     @.dims;
  has int32     $.direction;
  has fftw_plan $!plan;

  method execute() { … }

  method plan-save(Str $filename --> True)
  {
    fftw_export_wisdom_to_filename($filename) ||
      fail X::Libfftw3.new: errno => FILE-ERROR, error => "Can't create file $filename";
  }

  method plan-load(Str $filename --> True)
  {
    fftw_import_wisdom_from_filename($filename) ||
      fail X::Libfftw3.new: errno => FILE-ERROR, error => "Can't read file $filename";
  }
}
