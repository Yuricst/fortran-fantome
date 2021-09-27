!
! Sims-Flanagan Transcription 
!
! Yuri Shimane, Georgia Institute of Technology
! 2021.09.20
!

module simsflanagan

	use, intrinsic :: iso_fortran_env,    only: real64
	use keplerder

	implicit none
	private
	public :: eval_trajectory
	integer, parameter :: wp = real64

contains

	function eval_leg(n, sv0, tf, taus, thetas, betas, tmax, mdot, tol, maxiter) result(svf)
	! ===========================
	! Evaluate Sims-Flanagan leg
	! ===========================
	integer, intent(in) :: n
	real(wp), intent(in), dimension(7)  :: sv0
	real(wp), intent(out), dimension(7) :: svf
	real(wp), intent(in) :: tf
	real(wp), intent(in) :: taus(*), 
	real(wp), intent(in) :: thetas(*)
	real(wp), intent(in) :: betas(*)
	real(wp), intent(in) :: tmax, mdot, tol
	integer, intent(in)  :: maxiter

	end function eval_leg


	subroutine eval_trajectory(n, np, x, tmax, mdot, tol, maxiter, cs) bind(c, name="eval_trajectory")
	! ==================================
	! Evaluate Sims-Flanagan trajectory
	! ==================================
	integer, intent(in) :: n, np
	real(wp), intent(in) :: x(*)
	real(wp), intent(in) :: tol
	integer, intent(in)   :: maxiter
	real(wp), intent(out) :: cs(*)
	real(wp), intent(in)  :: tmax, mdot, tof

	real(wp) :: taus(*), 
	real(wp) :: thetas(*)
	real(wp) :: betas(*)

	real(wp), allocatable, dimension(:) :: cnodes

	! ! -------------------------------
	! ! UNPACK DECISION VECTOR
	! ! -------------------------------
	! do i = 1,np
	! 	cnodes = [cnodes, x()]
	! end

	! -------------------------------
	! ITERATE OVER PHASES
	! -------------------------------
	do i = 1,np
		! construct array of controls
		taus = 0 
		thetas = 0 
		betas = 0

		! construct forward control-node
		epoch, m_fwd, vinf, alf, beta = x(1:5)
		sv0_fwd = 0

		! construct backward control-node
		tof, m_bck, vinf, alf, beta = x(6:10)
		sv0_bck = 0

		! construct tof

		! evaluate forward leg
		svf_fwd = eval_leg(n, sv0_fwd, tof/2, taus, thetas, betas, tmax, mdot, tol, maxiter)

		! evaluate backward leg
		svf_bck = eval_leg(n, sv0_bck, -tof/2, taus, thetas, betas, tmax, mdot, tol, maxiter)

		! compute and store mismatch
		cmp = svf_bck - svf_fwd
	end do

	end subroutine eval_trajectory

end module simsflanagan