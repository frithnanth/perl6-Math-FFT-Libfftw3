use v6;

unit module Math::FFT::Libfftw3::Raw:ver<0.0.1>;

use NativeCall;
use Math::FFT::Libfftw3::Constants;

constant LIB = ('libfftw3.so.3', v3);

class fftw_plan is repr('CPointer') is export { * } # libfftw3 private struct
class fftw_iodim is repr('CPointer') is export { * } # libfftw3 private struct
class fftw_iodim64 is repr('CPointer') is export { * } # libfftw3 private struct
class fftw_r2r_kind is repr('CPointer') is export { * } # libfftw3 private struct

sub fftw_malloc(size_t $size --> Pointer) is native(LIB) is export { * }
sub fftw_free(Pointer $pointer) is native(LIB) is export { * }
sub fftw_alloc_real(size_t $size --> Pointer[num64]) is native(LIB) is export { * }
sub fftw_alloc_complex(size_t $size --> Pointer[num64]) is native(LIB) is export { * }

sub fftw_plan_dft(int32 $rank, CArray[int32] $n, CArray[num64] $in, CArray[num64] $out, int32 $sign, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_1d(int32 $n, CArray[num64] $in, CArray[num64] $out, int32 $sign, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_dft_2d(int32 $n0, int32 $n1, CArray[num64] $in, CArray[num64] $out, int32 $sign, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_3d(int32 $n0, int32 $n1, int32 $n2, CArray[num64] $in, CArray[num64] $out, int32 $sign,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_many_dft(int32 $rank, CArray[int32] $n, int32 $howmany, CArray[num64] $in, CArray[int32] $inembed,
    int32 $istride, int32 $idist, CArray[num64] $out, CArray[int32] $onembed, int32 $ostride, int32 $odist,
    int32 $sign, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_dft(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims, CArray[num64] $in,
    CArray[num64] $out, int32 $sign, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_split_dft(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $ro, CArray[num64] $io, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_guru64_dft(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, int32 $sign, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru64_split_dft(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $ro, CArray[num64] $io, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }

sub fftw_plan_many_dft_r2c(int32 $rank, CArray[int32] $n, int32 $howmany, CArray[num64] $in, CArray[int32] $inembed,
    int32 $istride, int32 $idist, CArray[num64] $out, CArray[int32] $onembed, int32 $ostride, int32 $odist,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_r2c(int32 $rank, CArray[int32] $n, CArray[num64] $in, CArray[num64] $out, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_r2c_1d(int32 $n, CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_dft_r2c_2d(int32 $n0, int32 $n1, CArray[num64] $in, CArray[num64] $out, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_r2c_3d(int32 $n0, int32 $n1, int32 $n2, CArray[num64] $in, CArray[num64] $out,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_dft_r2c(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_split_dft_r2c(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $in, CArray[num64] $ro, CArray[num64] $io, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_guru64_dft_r2c(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru64_split_dft_r2c(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $in, CArray[num64] $ro, CArray[num64] $io, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }

sub fftw_plan_many_dft_c2r(int32 $rank, CArray[int32] $n, int32 $howmany, CArray[num64] $in, CArray[int32] $inembed,
    int32 $istride, int32 $idist, CArray[num64] $out, CArray[int32] $onembed, int32 $ostride, int32 $odist,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_c2r(int32 $rank, CArray[int32] $n, CArray[num64] $in, CArray[num64] $out, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_c2r_1d(int32 $n, CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_dft_c2r_2d(int32 $n0, int32 $n1, CArray[num64] $in, CArray[num64] $out, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_dft_c2r_3d(int32 $n0, int32 $n1, int32 $n2, CArray[num64] $in, CArray[num64] $out,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_dft_c2r(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru_split_dft_c2r(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $out, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_guru64_dft_c2r(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_guru64_split_dft_c2r(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $out, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }

sub fftw_plan_many_r2r(int32 $rank, CArray[int32] $n, int32 $howmany, CArray[num64] $in, CArray[int32] $inembed,
    int32 $istride, int32 $idist, CArray[num64] $out, CArray[int32] $onembed, int32 $ostride, int32 $odist,
    fftw_r2r_kind $kind, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_r2r(int32 $rank, CArray[int32] $n, CArray[num64] $in, CArray[num64] $out, fftw_r2r_kind $kind,
    uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_r2r_1d(int32 $n, CArray[num64] $in, CArray[num64] $out, fftw_r2r_kind $kind, uint32 $flags
    --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_r2r_2d(int32 $n0, int32 $n1, CArray[num64] $in, CArray[num64] $out, fftw_r2r_kind $kind0,
    fftw_r2r_kind $kind1, uint32 $flags --> fftw_plan) is native(LIB) is export { * }
sub fftw_plan_r2r_3d(int32 $n0, int32 $n1, int32 $n2, CArray[num64] $in, CArray[num64] $out,
    fftw_r2r_kind $kind0, fftw_r2r_kind $kind1, fftw_r2r_kind $kind2, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_guru_r2r(int32 $rank, fftw_iodim $dims, int32 $howmany_rank, fftw_iodim $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, fftw_r2r_kind $kind, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }
sub fftw_plan_guru64_r2r(int32 $rank, fftw_iodim64 $dims, int32 $howmany_rank, fftw_iodim64 $howmany_dims,
    CArray[num64] $in, CArray[num64] $out, fftw_r2r_kind $kind, uint32 $flags --> fftw_plan)
    is native(LIB) is export { * }

sub fftw_execute(fftw_plan $p) is native(LIB) is export { * }
sub fftw_execute_dft(fftw_plan $p, CArray[num64] $in, CArray[num64] $out) is native(LIB) is export { * }
sub fftw_execute_split_dft(fftw_plan $p, CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $ro, CArray[num64] $io)
    is native(LIB) is export { * }
sub fftw_execute_dft_r2c(fftw_plan $p, CArray[num64] $in, CArray[num64] $out) is native(LIB) is export { * }
sub fftw_execute_dft_c2r(fftw_plan $p, CArray[num64] $in, CArray[num64] $out) is native(LIB) is export { * }
sub fftw_execute_split_dft_r2c(fftw_plan $p, CArray[num64] $in, CArray[num64] $ro, CArray[num64] $io)
    is native(LIB) is export { * }
sub fftw_execute_split_dft_c2r(fftw_plan $p, CArray[num64] $ri, CArray[num64] $ii, CArray[num64] $out)
    is native(LIB) is export { * }
sub fftw_execute_r2r(fftw_plan $p, CArray[num64] $in, CArray[num64] $out) is native(LIB) is export { * }

sub fftw_destroy_plan(fftw_plan $p) is native(LIB) is export { * }
sub fftw_forget_wisdom() is native(LIB) is export { * }
sub fftw_cleanup() is native(LIB) is export { * }
sub fftw_set_timelimit(num64 $t) is native(LIB) is export { * }

sub fftw_plan_with_nthreads(int32 $nthreads) is native(LIB) is export { * }
sub fftw_init_threads(--> int32) is native(LIB) is export { * }
sub fftw_cleanup_threads() is native(LIB) is export { * }



=begin pod

=head1 NAME

Math::FFT::Libfftw3::Raw - An interface to libfftw3

=head1 SYNOPSIS
=begin code

use v6;

=end code

=head1 DESCRIPTION

For more details on libfftw3 see L<http://fftw.org/>.

=head1 Prerequisites

This module requires the libfftw3 library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libfftw3-double3
=end code

The module looks for a library called libfftw3.so.

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::FFT::Libfftw3
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
