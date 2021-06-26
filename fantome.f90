!
! FANTOM module
! FortrAN TrajectOry Module
!
! Grouping all modules into library
!
! Compile as:
! > gfortran linalg.f90 orbitalelements.f90 keplerder.f90 fantome.f90 -o fantome.so
!
!

module fantom

	use orbitalelements
	use keplerder
	implicit none
	public
	
end module fantom