! Solves for the new solution vector
! 
! Input:
! 
! Output:
! 

subroutine solve_soln_transient(isotope,delay_group,n, nl_iter )

    USE parameters_fe

    implicit none

!---Dummy
    integer,intent(in) :: isotope
    integer,intent(in) :: delay_group
    integer,intent(in) :: nl_iter
    integer,intent(in) :: n

!---Local
    integer :: i,j,f,g

!---PRECURSOR SOLVE
    do i = 1, nodes_per_elem
        precursor_soln_new(isotope,delay_group, n,i) = &
            precursor_soln_prev(isotope, delay_group, n,i) + &
            delta_t*( H_times_soln_vec(i) + &
            (beta_i_mat(isotope,delay_group)/gen_time)*&
            elem_vec_A_times_q(i) + A_times_W_times_upwind_elem_vec(i) )
    end do
!---END PRECURSOR SOLVE    
    
!---Write out solution for current element 
    write(outfile_unit,fmt='(a)'), ' ' 
    write(outfile_unit,fmt='(a,1I3,a,1I3)'),'Solution | element --> ', n, ' isotope -->',isotope
    do j=1,nodes_per_elem 
          write(outfile_unit,fmt='(a,1I2,12es14.3)'), 'Node -->', n-1+j, precursor_soln_new(isotope, delay_group,n,j)          
    end do   
    write(outfile_unit,fmt='(a)'), '********************************'

end subroutine solve_soln_transient  
