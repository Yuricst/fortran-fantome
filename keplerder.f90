!
! Kepler-Der algorithm
!
! Yuri Shimane, Georgia Institute of Technology
! 2021.06.17
!

module keplerder
	
	use, intrinsic :: iso_fortran_env,    only: real64
	use linalg
	use orbitalelements
	
	implicit none
	private
	public :: propagate
	public :: test1
	public :: universal_functions, hypertrig_c, hypertrig_s, kepler_der_function, lagrange_coefficients
	integer, parameter :: wp = real64
	
contains

	function universal_functions(x, alpha) result(us)
	! =============================
	! Evaluate universal functions
	! =============================
		implicit none
		real(wp), intent(in) :: x, alpha
		real(wp), dimension(4) :: us
		real(wp) :: u0, u1, u2, u3, S, C
		
		! evaluate hypertrig function
		S = hypertrig_s(alpha*x**2)
		C = hypertrig_c(alpha*x**2)
		
		! parameters
		u0 = 1 - alpha * x**2 * C
		u1 = x*(1 - alpha * x**2 * S)
		u2 = x**2 * C
		u3 = x**3 * S
		us = (/ u0, u1, u2, u3 /)

	end function universal_functions


	function hypertrig_c(z) result(c)
	! =======================
	! evaluate hypertric cos
	! =======================
		implicit none
		real(wp), intent(in) :: z
		real(wp) :: c
		
		if (z > 0.0) then 
			c = (1.0 - cos(sqrt(z)))/z
		elseif (z < 0.0) then
			c = (cosh(-z) - 1)/(-z)
		else
			c = 0.5
		end if
	end function hypertrig_c


	function hypertrig_s(z) result(s)
	! =======================
	! evaluate hypertric sin
	! =======================
		implicit none
		real(wp), intent(in) :: z
		real(wp) :: s
		
		if (z > 0.0) then 
			s = (sqrt(z)-sin(sqrt(z))) / (sqrt(z))**3
		elseif (z < 0.0) then
			s = (sinh(sqrt(-z)) - sqrt(-z)) / (sqrt(-z))**3
		else
			s = 1.0/6.0
		end if
	end function hypertrig_s


	function kepler_der_function(x, alpha, t, t0, sqrt_mu, r0_norm, sigma0) result(f_derivs_array)
	! ==========================================
	! Kepler-Der function, 1st, 2nd derivatives
	! ==========================================
		
		implicit none
		real(wp), intent(in) :: x, alpha, t, t0, sqrt_mu, r0_norm, sigma0
		real(wp), dimension(3) :: f_derivs_array
		real(wp), dimension(4) :: us
		real(wp) :: fun, dfun, d2fun
		
		us = universal_functions(x, alpha)
		
		fun   = r0_norm*us(2) + sigma0*us(3) + us(4) - sqrt_mu * (t - t0)
		dfun  = r0_norm*us(1) + sigma0*us(2) + us(3)
		d2fun = sigma0*us(1) + (1 - alpha*r0_norm)*us(2)
		f_derivs_array = (/ fun, dfun, d2fun /)
		 
	end function kepler_der_function

	
	function lagrange_coefficients(sqrt_mu, alpha, r0, v0, sigma0, u0, u1, u2, u3, r, sigma) result(lagrange_coefs)
	! ==============================
	! compute Lagrange coefficients
	! ==============================
	implicit none
	real(wp) :: sqrt_mu, alpha, r0, v0, sigma0, u0, u1, u2, u3, r, sigma
	real(wp), dimension(4) :: lagrange_coefs
	real(wp) :: f, g, fdot, gdot
	
	! evaluate scalar functions
	f = 1.0 - u2/r0
	g = r0*u1 / sqrt_mu + sigma0*u2 / sqrt_mu
	fdot = -sqrt_mu / (r*r0) * u1
	gdot = 1.0 - u2/r
	! store for output
	lagrange_coefs = (/ f, g, fdot, gdot /)
	 
	end function lagrange_coefficients
	
	
	subroutine propagate(state1, mu, state0, t0, t, tol, maxiter) bind(c, name="propagate")
	! ================================
	! Kepler-Der propagation of state
	! ================================
		implicit none
		real(wp), dimension(6), intent(in)  :: state0
		real(wp), intent(in)                :: mu, t0, t, tol
		integer, intent(in)                 :: maxiter
		real(wp), dimension(6), intent(out) :: state1
		
		real(wp) :: alpha, sigma0, sqrt_mu, ecc, x0, x1, fun, dfun, d2fun, r0_norm, v0_norm
		real(wp), dimension(3) :: f_derivs_array
		integer :: counter
		real(wp), dimension(4) :: us, lagrange_coefs
		real(wp) :: r_scal, sigma, f, fdot, g, gdot
		integer :: i
		real(wp), dimension(6,6) :: statemap
		
		! -------------------------------
		! SET-UP PROBLEM
		! -------------------------------
		sqrt_mu = sqrt(mu)
		r0_norm = norm2_vec3(state0(1:3))
		v0_norm = norm2_vec3(state0(4:6))
		alpha   = 1/state2sma(state0, mu)
		sigma0  = dot_vec3(state0(1:3), state0(4:6)) / sqrt_mu
	
		! -------------------------------
		! ITERATE LAGUERRE-CONWAY METHOD
		! -------------------------------
		! construct initial guess from eccentricity
		ecc = state2ecc(state0, mu)
		if (ecc < 1) then
			x0 = alpha * sqrt_mu*(t-t0)
		else
			x0 = sqrt_mu * (t-t0) / (10*norm2_vec3(state0(1:3)))
		end if
		! iterate
		counter = 0
		do while (counter < maxiter)
			! compute kepler-der function
			f_derivs_array = kepler_der_function(x0, alpha, t, t0, sqrt_mu, r0_norm, sigma0)
			fun   = f_derivs_array(1)
			dfun  = f_derivs_array(2)
			d2fun = f_derivs_array(3)
			! exit if tolerance is achieved
			if (abs(fun) < tol) then
				exit
			end if
			! Laguerre-Conway update
			x1 = x0 - 5*fun / (dfun + dfun/abs(dfun) * sqrt(abs(16*dfun**2 - 20*fun*d2fun)) )
			! updates
			x0 = x1
			counter = counter + 1
		end do
		
		! -------------------------------
		! COMPUTE FINAL POSITION
		! -------------------------------
		us = universal_functions(x1, alpha)
		r_scal = r0_norm*us(1) + sigma0*us(2) + us(3)
		sigma = sigma0*us(1) + (1 - alpha*r0_norm)*us(2)

		! get lagrange coefficients
		lagrange_coefs = lagrange_coefficients(mu, alpha, r0_norm, v0_norm, sigma0, us(1), us(2), us(3), us(4), r_scal, sigma)
		f    = lagrange_coefs(1)
		g    = lagrange_coefs(2)
		fdot = lagrange_coefs(3)
		gdot = lagrange_coefs(4)
		
		! create state map
		statemap = 0.0
		do i = 1,3
			statemap(i,i)     = f
			statemap(i,3+i)   = g
			statemap(3+i,i)   = fdot
			statemap(3+i,3+i) = gdot
		end do
		! propagate state
		state1 = matmul(statemap, state0)
		
	end subroutine propagate
	
end module keplerder


! -----------------------------------------------------------
program test_keplerder

	use, intrinsic :: iso_fortran_env,    only: real64
	use keplerder
	implicit none
	
	integer, parameter :: wp = real64
		
	real(wp), dimension(6) :: state1, state0
	real(wp) :: mu, t0, t, tol
	integer :: maxiter
	
	print*, "Testing Kepler-Der module"

	! initial values
	mu = 1.0_wp
	t0 = 0.0_wp
	t = 3.14_wp
	tol = 1E-12_wp
	maxiter = 20
	state0 = [ 1.01_wp, 0.0_wp, 0.2_wp, 0.0_wp, 0.98_wp, 0.067_wp ]
	
	! call subroutine
	print*, "state0: "
	print*, state0
	call propagate(state1, mu, state0, t0, t, tol, maxiter)
	print*, "state1: "
	print*, state1
	
end program test_keplerder
