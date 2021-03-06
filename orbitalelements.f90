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
!   > gfortran linalg.f90 orbitalelements.f90 -o orbel
!
! -----------------------------------------------------------
module orbitalelements
    
    use, intrinsic :: iso_fortran_env,    only: real64
    use linalg
    implicit none
    private
    public :: state2h, state2sma, state2ecc, state2inc, state2raan, state2aop, state2ta
    public :: state2kepelts
    public :: kepelts2state
    public :: rad2deg, deg2rad

    real(real64), parameter :: pi_16 = 4.0_real64 * atan (1.0_real64)
    
contains
    
    function state2h(state) result(hvec)
    ! =========================================
    ! Convert state to angular momentum vector
    ! =========================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), dimension(3) :: hvec
        hvec = cross(state(1:3), state(4:6))
    end function state2h
    
    
    function state2ecc(state, mu) result(ecc)
    ! =======================================
    ! Convert state to eccentricity vector
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64), dimension(3) :: hvec, ecc_vec
        real(real64) :: ecc
        
        hvec = cross(state(1:3), state(4:6))
        ecc_vec = (1/mu) * cross(state(4:6),hvec) - state(1:3)/norm2(state(1:3))
        ecc = norm2(ecc_vec)
    end function state2ecc
    
    
    function state2sma(state, mu) result(sma)
    ! =======================================
    ! Convert state to semi-major axis
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64) :: sma, h, ecc
        
        h = norm2(cross(state(1:3), state(4:6)))
        ecc = state2ecc(state, mu)
        sma = h**2 / (mu*(1 - ecc**2))
        ! energy = 0.5*norm2(state(4:6))**2 - mu/norm2(state(1:3))
        ! sma = -mu/(2*energy)
    end function state2sma
    

    function state2inc(state) result(inc)
    ! =======================================
    ! Convert state to inclination
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), dimension(3) :: hvec
        real(real64) :: inc
        
        hvec = cross(state(1:3), state(4:6))
        inc = acos(hvec(3) / norm2(hvec))
        
    end function state2inc
    
    
    function state2raan(state) result(raan)
    ! =======================================
    ! Convert state to raan
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), dimension(3) :: hvec, zdir, ndir
        real(real64) :: raan
        
        hvec = cross(state(1:3), state(4:6))
        zdir = (/ 0.0, 0.0, 1.0 /)
        ndir = cross(zdir, hvec)
        
        if (ndir(2) >= 0) then
            raan = acos(ndir(1)/norm2(ndir))
        else
            raan = 2*pi_16 - acos(ndir(1)/norm2(ndir))
        end if
        
    end function state2raan
    
    
    function state2aop(state, mu) result(aop)
    ! =======================================
    ! Convert state to argument of periapsis
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64), dimension(3) :: hvec, zdir, ndir, evec
        real(real64) :: aop
        
        hvec = cross(state(1:3), state(4:6))
        zdir = (/ 0.0, 0.0, 1.0 /)
        ndir = cross(zdir, hvec)
        evec = (1/mu) * cross(state(4:6),hvec) - state(1:3)/norm2(state(1:3))
        
        if (norm2(ndir)*norm2(evec)/=0.0) then
            aop = acos( dot_product(ndir,evec) / (norm2(ndir)*norm2(evec)) )
            if (evec(3) < 0.0) then
                aop = 2*pi_16 - aop
            end if
        else
            aop = 1000.0
        end if      
        
    end function state2aop
    

    function state2ta(state, mu) result(ta)
    ! =======================================
    ! Convert state to true anomaly
    ! =======================================
        implicit none
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64), dimension(3) :: evec, hvec
        real(real64) ta, vr
        
        hvec = cross(state(1:3), state(4:6))
        evec = (1/mu) * cross(state(4:6),hvec) - state(1:3)/norm2(state(1:3))
        
        ! compute radial velocity
        vr = dot_product(state(4:6),state(1:3))/norm2(state(1:3))
        ! compute true anomaly
        ta = acos(dot_product(state(1:3), evec)/(norm2(state(1:3))*norm2(evec)))
        if (vr < 0.0) then
            ta = 2*pi_16 - ta
        end if
        
    end function state2ta
    

    function rad2deg(angle) result(angle_deg)
    ! =======================================
    ! Convert angle from radian to degrees
    ! =======================================
        implicit none
        real(real64), intent(in) :: angle
        real(real64) :: angle_deg
        angle_deg = angle * 180.0 / pi_16
    end function rad2deg
    
    
    function deg2rad(angle) result(angle_rad)
    ! =======================================
    ! Convert angle from degrees to radians
    ! =======================================
        implicit none
        real(real64), intent(in) :: angle
        real(real64) :: angle_rad
        angle_rad = angle * pi_16 / 180.0
    end function deg2rad
    
    
    subroutine state2kepelts(kepelts, state, mu)
    ! ============================================
    ! Obtain keplerian elements from state-vector
    !
    ! elements order: [sma, inc, raan, ecc, aop, ta]
    ! ============================================
        implicit none 
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64), dimension(6), intent(out) :: kepelts
        
        ! in order: sma, inc, raan, ecc, aop, ta
        kepelts(1) = state2sma(state, mu)
        kepelts(2) = state2inc(state)
        kepelts(3) = state2raan(state)
        kepelts(4) = state2ecc(state, mu)
        kepelts(5) = state2aop(state, mu)
        kepelts(6) = state2ta(state, mu)
        
    end subroutine


    subroutine kepelts2state(state, kepelts, mu)
    ! ============================================
    ! Obtain state-vector from keplerian elements
    !
    ! state: [r, v]
    ! ============================================
        implicit none 
        real(real64), dimension(6), intent(in) :: state
        real(real64), intent(in) :: mu
        real(real64), dimension(6), intent(out) :: kepelts
        
        ! in order: sma, inc, raan, ecc, aop, ta
        kepelts(1) = state2sma(state, mu)
        kepelts(2) = state2inc(state)
        kepelts(3) = state2raan(state)
        kepelts(4) = state2ecc(state, mu)
        kepelts(5) = state2aop(state, mu)
        kepelts(6) = state2ta(state, mu)
        
    end subroutine

    
end module orbitalelements


! ! -----------------------------------------------------------
! program test_orbel
    
    ! use, intrinsic :: iso_fortran_env,    only: real64
    
    ! use orbitalelements
    ! implicit none
    ! integer :: foo, bar
    ! real(real64), dimension(6) :: state, kepelts
    ! real(real64) :: mu, sma, ecc, inc, raan, aop, ta
    
    ! mu = 1.0
    ! state = (/ 1.0, 0.0, 0.2, 0.0, 0.98, 0.067 /)
    
    ! inc = state2inc(state)
    ! raan = state2raan(state)
    ! sma = state2sma(state, mu)
    ! ecc = state2ecc(state, mu)
    ! aop = state2aop(state, mu)
    ! ta  = state2ta(state, mu)
    
    ! ! print results
    ! print*, "sma:  ", sma
    ! print*, "ecc:  ", ecc
    ! print*, "inc:  ", inc
    ! print*, "raan: ", raan
    ! print*, "aop:  ", aop
    ! print*, "ta:   ", ta
    
    ! ! getting all elements from subroutine
    ! call state2kepelts(kepelts, state, mu)
    ! print*, kepelts
    
! end program test_orbel
    
