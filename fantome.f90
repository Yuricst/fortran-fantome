!
! FANTOM module
! FortrAN TrajectOry Module
!
! Grouping all modules into library
!
! Compile as:
! > gfortran linalg.f90 orbitalelements.f90 keplerder.f90 simsflanagan.f90 fantome.f90 test_fantome.f90 -o run.so
!
!

module fantom

    use orbitalelements
    use keplerder
    !use simsflanagan
    implicit none
    public
    
end module fantom


