!
! Compile as:
! > gfortran linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90 test_fantome.f90 -o run.so
!
! -----------------------------------------------------------

program test_keplerder

	use, intrinsic :: iso_fortran_env,    only: real64
	use fantom
	implicit none
	
	integer, parameter :: wp = real64
		
	real(wp), dimension(6) :: state1, state0
	real(wp) :: mu, t0, t, tol
	integer :: maxiter
	
	print*, "Testing Fantome module"

	! initial values
	mu = 1.0_wp
	t0 = 0.0_wp
	t = 3.14_wp
	tol = 1E-12_wp
	maxiter = 20
	state0 = [ 1.01_wp, 0.0_wp, 0.2_wp, 0.0_wp, 0.98_wp, 0.067_wp ]
	
	! call subroutine
	print*, "Kepler-der: "
	print*, "state0: "
	print*, state0
	call propagate(mu, state0, state1, t0, t, tol, maxiter)
	print*, "state1: "
	print*, state1
	
end program test_keplerder
