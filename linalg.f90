!
! Simple linear-algebra routines
!

module linalg
	
	use, intrinsic :: iso_fortran_env,    only: real64
	implicit none
	private
	public :: crossproduct, norm2_vec3, dot_vec3, matmul6
	integer, parameter :: wp = real64
	
contains

	! -----------------------------------------
	! Compute cross-product
	function crossproduct(v1,v2) result(v3)
		implicit none
		real(wp), dimension(3), intent(in) :: v1, v2
		real(wp), dimension(3) :: v3
		v3(1) = v1(2) * v2(3) - v1(3) * v2(2)
		v3(2) = v1(3) * v2(1) - v1(1) * v2(3)
		v3(3) = v1(1) * v2(2) - v1(2) * v2(1)
	end function crossproduct
	
	
	! ----------------------------------------
	! Compute 2-norm of 3-element vector
	function norm2_vec3(vector) result(norm_val)
		implicit none
		real(wp), dimension(3) :: vector
		real(wp) :: norm_val
		
		norm_val = (vector(1)**2 + vector(2)**2 + vector(3)**2)**0.5
	end function norm2_vec3
	
	! ----------------------------------------
	! Compute dot product of 3-element vector
	function dot_vec3(v1, v2) result(dotpro)
		implicit none
		real(wp), dimension(3) :: v1, v2
		real(wp) :: dotpro
		
		dotpro = v1(1)*v2(1) + v1(2)*v2(2) + v1(3)*v2(3)
		
	end function dot_vec3
	
	! ----------------------------------------
	! compute 6x6 matrix * length-6 vector
	function matmul6(mat, vec) result(prod)
		implicit none
		real(wp), dimension(6,6), intent(in) :: mat
		real(wp), dimension(6), intent(in) :: vec
		real(wp), dimension(6) :: prod
		integer :: i
		
		do i = 1,6
			prod(i) = mat(i,1)*vec(1) + mat(i,2)*vec(2) + mat(i,3)*vec(3) + mat(i,4)*vec(4) + mat(i,5)*vec(5) + mat(i,6)*vec(6)
		end do
		
	end function matmul6

end module linalg


! program test_module

	! use linalg
	! implicit none
	! real(wp), dimension(3) :: r1, r2, r3
	
	! r1 = (/ 1.0, 2.0, 3.0 /)
	! r2 = (/ 5.0, 7.0, -2.0 /)
	
	! r3 = crossproduct(r1, r2)
	! print*, r3
	
! end program test_module