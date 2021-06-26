!
! Simple linear-algebra routines
!

module linalg
	
	use, intrinsic :: iso_fortran_env,    only: real64
	implicit none
	private
	public :: cross
	integer, parameter :: wp = real64
	
contains

	function cross(r,v) result(rxv)
	! =============================
	! cross product
	! =============================

    implicit none

    real(wp),dimension(3),intent(in) :: r
    real(wp),dimension(3),intent(in) :: v
    real(wp),dimension(3)            :: rxv

    rxv = [r(2)*v(3) - v(2)*r(3), &
           r(3)*v(1) - v(3)*r(1), &
           r(1)*v(2) - v(1)*r(2) ]

	end function cross

end module linalg