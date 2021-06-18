!
! Orbital elements routines
!
! Yuri Shimane, Georgia Institute of Technology
! 2021.06.17
!
! Compiling:
!
!   > gfortran linalg.f90 orbitalElements.f90
!

! -----------------------------------------------------------
module orbitalElements

	use linalg
	implicit none
	private
	public :: state2h, state2sma, state2ecc
	
contains
	
	! -----------------------------------------
	! Convert state to angular momentum vector
	function state2h(state) result(hvec)
		implicit none
		real, dimension(6), intent(in) :: state
		real, dimension(3) :: hvec
		hvec = crossproduct(state(1:3), state(4:6))
	end function state2h
	
	
	! -----------------------------------------
	! Convert state to eccentricity vector
	function state2ecc(state, mu) result(ecc)
		implicit none
		real, dimension(6), intent(in) :: state
		real, intent(in) :: mu
		real, dimension(3) :: hvec, ecc_vec
		real :: ecc
		
		hvec = crossproduct(state(1:3), state(4:6))
    ecc_vec = (1/mu) * crossproduct(state(4:6),hvec) - state(1:3)/norm2_vec3(state(1:3))
		ecc = norm2_vec3(ecc_vec)
	end function state2ecc
	
	
	! -----------------------------------------
	! Convert state to semi-major axis
	function state2sma(state, mu) result(sma)
		implicit none
		real, dimension(6), intent(in) :: state
		real, intent(in) :: mu
		real :: sma, h, ecc
		
		h = norm2_vec3(crossproduct(state(1:3), state(4:6)))
		ecc = state2ecc(state, mu)
		sma = h**2 / (mu*(1 - ecc**2))
	end function state2sma
	
	
end module orbitalElements


! -----------------------------------------------------------
program test_orbel

	use orbitalElements
	implicit none
	integer :: foo, bar
	real, dimension(6) :: state
	real :: mu, sma, ecc
	
	mu = 1.0
	state = (/ 1.0, 0.0, 0.2, 0.0, 0.98, 0.067 /)
	
	sma = state2sma(state, mu)
	ecc = state2ecc(state, mu)
	print*, "sma: ", sma
	print*, "ecc: ", ecc
	
end program test_orbel
	