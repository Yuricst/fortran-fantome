!
! Simple linear-algebra routines
!

module linalg

	implicit none
	private
	public :: crossproduct, norm2_vec3

contains

	! -----------------------------------------
	! Compute cross-product
	function crossproduct(v1,v2) result(v3)
		implicit none
		real, dimension(3), intent(in) :: v1, v2
		real, dimension(3) :: v3
		v3(1) = v1(2) * v2(3) - v1(3) * v2(2)
		v3(2) = v1(3) * v2(1) - v1(1) * v2(3)
		v3(3) = v1(1) * v2(2) - v1(2) * v2(1)
	end function crossproduct
	
	
	! ----------------------------------------
	! Compute 2-norm of 3-element vector
	function norm2_vec3(vector) result(norm_val)
		implicit none
		real, dimension(3) :: vector
		real :: norm_val
		
		norm_val = (vector(1)**2 + vector(2)**2 + vector(3)**2)**0.5
	end function norm2_vec3
	

end module linalg


! program test_module

	! use linalg
	! implicit none
	! real, dimension(3) :: r1, r2, r3
	
	! r1 = (/ 1.0, 2.0, 3.0 /)
	! r2 = (/ 5.0, 7.0, -2.0 /)
	
	! r3 = crossproduct(r1, r2)
	! print*, r3
	
! end program test_module