! Solves for the new solution vector
!
! 
! Input:
! 
! Output:
!
! 
subroutine solve_soln_transient(n, nl_iter )

    USE parameters_fe

    implicit none

!---Dummy
    integer,intent(in) :: nl_iter
    integer,intent(in) :: n

!---Local
    integer :: i,j
    real, dimension(3)   :: rhs_final_vec, temp_H_vec 
    real, dimension(3,3) :: inverse_matrix

!---PRECURSOR SOLVE
    
    do i = 1, nodes_per_elem
        precursor_soln_new(n,i) = precursor_soln_prev(n,i) + &
        delta_t*(H_times_soln_vec(i) + elem_vec_A_times_q(i) + A_times_W_times_upwind_elem_vec(i) )
        print *, ' diff',temp_H_vec(i) + elem_vec_q(i) + A_times_W_times_upwind_elem_vec(i), ' at n', n, 't0',t0
    end do
    !print *, ' '
!---END PRECURSOR SOLVE    

    write(outfile_unit,fmt='(a)'), ' ' 
    write(outfile_unit,fmt='(a,1I3)'),'Solution | element --> ', n
    do j=1,nodes_per_elem 
          write(outfile_unit,fmt='(a,1I2,12es14.3)'), 'Node -->', n-1+j, precursor_soln_new(n,j)          
    end do   
    write(outfile_unit,fmt='(a)'), '********************************'
 end
