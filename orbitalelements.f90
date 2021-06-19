!
! Orbital elements routines
!
! Yuri Shimane, Georgia Institute of Technology
! 2021.06.17
!
! Compiling:
!
!   > gfortran linalg.f90 orbitalelements.f90
!
! or:
!   > gfortran -o orbel linalg.f90 orbitalelements.f90
!

! -----------------------------------------------------------
module orbitalelements

	use linalg
	implicit none
	private
	public :: state2h, state2sma, state2ecc, state2inc, state2raan, state2aop, state2ta
	public :: state2kepelts
	public :: rad2deg, deg2rad
	real(16), parameter :: pi_16 = 4 * atan (1.0_16)
	
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
	
	
	! -----------------------------------------
	! Convert state to inclination
	function state2inc(state) result(inc)
		implicit none
		real, dimension(6), intent(in) :: state
		real, dimension(3) :: hvec
		real :: inc
		
		hvec = crossproduct(state(1:3), state(4:6))
		inc = acos(hvec(3) / norm2_vec3(hvec))
		
	end function state2inc
	
	
	! -----------------------------------------
	! Convert state to raan
	function state2raan(state) result(raan)
		implicit none
		real, dimension(6), intent(in) :: state
		real, dimension(3) :: hvec, zdir, ndir
		real :: raan
		
		hvec = crossproduct(state(1:3), state(4:6))
		zdir = (/ 0.0, 0.0, 1.0 /)
		ndir = crossproduct(zdir, hvec)
		
		if (ndir(2) >= 0) then
			raan = acos(ndir(1)/norm2_vec3(ndir))
		else
			raan = 2*pi_16 - acos(ndir(1)/norm2_vec3(ndir))
		end if
		
	end function state2raan
	
	
	! -----------------------------------------
	! Convert state to argument of periapsis
	function state2aop(state, mu) result(aop)
		implicit none
		real, dimension(6), intent(in) :: state
		real, intent(in) :: mu
		real, dimension(3) :: hvec, zdir, ndir, evec
		real :: aop
		
		hvec = crossproduct(state(1:3), state(4:6))
		zdir = (/ 0.0, 0.0, 1.0 /)
		ndir = crossproduct(zdir, hvec)
		evec = (1/mu) * crossproduct(state(4:6),hvec) - state(1:3)/norm2_vec3(state(1:3))
		
		if (norm2_vec3(ndir)*norm2_vec3(evec)/=0.0) then
			aop = acos( dot_vec3(ndir,evec) / (norm2_vec3(ndir)*norm2_vec3(evec)) )
			if (evec(3) < 0.0) then
				aop = 2*pi_16 - aop
			end if
		else
			aop = 1000.0
		end if		
		
	end function state2aop
	
	
	! -----------------------------------------
	! Convert state to true anomaly
	function state2ta(state, mu) result(ta)
		implicit none
		real, dimension(6), intent(in) :: state
		real, intent(in) :: mu
		real, dimension(3) :: evec, hvec
		real ta, vr
		
		hvec = crossproduct(state(1:3), state(4:6))
		evec = (1/mu) * crossproduct(state(4:6),hvec) - state(1:3)/norm2_vec3(state(1:3))
		
		! compute radial velocity
		vr = dot_vec3(state(4:6),state(1:3))/norm2_vec3(state(1:3))
		! compute true anomaly
		ta = acos(dot_vec3(state(1:3), evec)/(norm2_vec3(state(1:3))*norm2_vec3(evec)))
		if (vr < 0.0) then
			ta = 2*pi_16 - ta
		end if
		
	end function state2ta
	
	
	! convert angle from radian to degrees
	function rad2deg(angle) result(angle_deg)
		implicit none
		real, intent(in) :: angle
		real :: angle_deg
		angle_deg = angle * 180.0 / pi_16
	end function rad2deg
	
	
	! convert angle from degrees to radians
	function deg2rad(angle) result(angle_rad)
		implicit none
		real, intent(in) :: angle
		real :: angle_rad
		angle_rad = angle * pi_16 / 180.0
	end function deg2rad
	
	
	! subroutine to obtain orbital elements
	subroutine state2kepelts(state, mu, kepelts)
		implicit none 
		real, dimension(6) :: state, kepelts
		real :: mu
		
		! in order: sma, inc, raan, ecc, aop, ta
		kepelts(1) = state2sma(state, mu)
		kepelts(2) = state2inc(state)
		kepelts(3) = state2raan(state)
		kepelts(4) = state2ecc(state, mu)
		kepelts(5) = state2aop(state, mu)
		kepelts(6) = state2ta(state, mu)
		
	end subroutine
	
end module orbitalelements


! -----------------------------------------------------------
program test_orbel

	use orbitalelements
	implicit none
	integer :: foo, bar
	real, dimension(6) :: state, kepelts
	real :: mu, sma, ecc, inc, raan, aop, ta
	
	mu = 1.0
	state = (/ 1.0, 0.0, 0.2, 0.0, 0.98, 0.067 /)
	
	inc = state2inc(state)
	raan = state2raan(state)
	sma = state2sma(state, mu)
	ecc = state2ecc(state, mu)
	aop = state2aop(state, mu)
	ta  = state2ta(state, mu)
	
	! print results
	print*, "sma:  ", sma
	print*, "ecc:  ", ecc
	print*, "inc:  ", inc
	print*, "raan: ", raan
	print*, "aop:  ", aop
	print*, "ta:   ", ta
	
	! getting all elements from subroutine
	call state2kepelts(state, mu, kepelts)
	print*, kepelts
	
end program test_orbel
	
