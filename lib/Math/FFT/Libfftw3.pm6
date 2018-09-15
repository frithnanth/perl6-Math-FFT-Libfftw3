use v6;

unit class Math::FFT::Libfftw3:ver<0.0.1>;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;

constant TYPE-ERROR          is export = 1;

class X::Libfftw3 is Exception
{
  has Int $.errno;
  has Str $.error;
  method message { "Error {$!errno}: $!error" }
}

has num64 @.carrdata;

submethod BUILD(Positional :$data!, Bool :$pair? = False)
{
  given $data[0].^name {
    when 'Complex' {
      @!carrdata := CArray[num64].new: $data.map(|*)».reals.flat.flat;
    }
    when 'Int' | 'Num' {
      my @in2 = 0 xx ($data.elems * 2);
      for $data.pairs -> $p {
        @in2[$p.key * 2] = $p.value;
      }
      @!carrdata := CArray[num64].new: @in2».Num.flat;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Num or Complex';
    }
  }
  if $pair {
    given $data[0].^name {
      when 'Int' | 'Num' {
        @!carrdata := CArray[num64].new: $data».Num.flat;
      }
      default {
        fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int or Num';
      }
    }
  }
}

=begin pod


=end pod
