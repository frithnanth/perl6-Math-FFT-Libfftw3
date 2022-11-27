use v6;

class X::Libfftw3:ver<0.3.5>:auth<zef:FRITH> is Exception
{
  has Int $.errno;
  has Str $.error;
  method message { "Error {$!errno}: $!error" }
}
