! Steady state solve of the equation 
!
! Input:
!
! Output:
! 
subroutine steady_state()

    USE parameters_fe

implicit none

!---Dummy

!---Local
    integer :: f,g,i,jj,j,n, nl_iter
    real    :: ii, elem_length, density, &
            center_temp_initial,  &
            norm_sin,norm_cos, pi, cosine_term, x_last, x_curr
    parameter (pi = 3.1415926535897932)
    character(len=20) :: ss_file_name
    real, dimension(num_elem) :: temp_vec_prec
    real :: total_precursor_ref, total_precursors_fuel
    real :: total_fuel_length
    real, dimension(num_isotopes,num_delay_group) :: L2_norm_current,L2_norm_prev 
    real :: nl_iter_tolerance, difference_L2    
    integer :: difference_counter
    integer :: abs_max_nl_iter
!---------------------------------------------------------------
   
    L2_norm_prev = 0.0
    L2_norm_current = 0.0
    nl_iter_tolerance = 1E-15
    abs_max_nl_iter = 1500
!---Normal calculation flow - no need if doing unit test
    if (unit_test .eqv. .FALSE.) then
        !---Set starting values for power, velocity, temperature 
        call initialize
                
        do i = 1,num_elem 
            do j = 1,nodes_per_elem
                velocity_soln_prev(i,j) = velocity_soln_new(i,j) 
            end do
        end do 
        nl_iter=1 
        
	!-----------------------------------------------------------------------
    !---Steady state solver for nonlinear ss problems
        write(outfile_unit, fmt='(a)'), ' ' 
        write(outfile_unit, fmt='(a)'), 'Start steady state calculation'
        
        difference_counter = 0
        do !---Nonlinear loop
            do n = 1, num_elem
                !---Computer spatial matrices 
	            call spatial_matrices(n,nl_iter)
                call numerical_flux_matrices(n,nl_iter)
                !---Solve steady state system 
                do f = 1, num_isotopes
                    do g = 1, num_delay_group
                        !---Assemble K, F
                        call assemble_matrix_ss(f,g,n)
                        call solve_precursor_ss(f,g,n,nl_iter)
                    end do !---Over delayed groups
                end do !---Over isotopes
            end do !---Over nodes

            !---Write out the solution
            if(DEBUG .eqv. .TRUE.) then
                call write_out_soln(outfile_unit,num_elem,transient_save_flag) 
            end if

            !---Swap for for next iteration
            precursor_soln_prev = precursor_soln_new
            
                        !---Calculate L2 norm to decide when enough iterations are complete 
            !if(nl_iter > 1) then
            !     
            !     do f = 1, num_isotopes
            !        do g = 1, num_delay_group
            !            L2_norm_current(f,g) = sqrt ( sum ( precursor_soln_new(f,g,:,:)*&
            !                                   precursor_soln_new(f,g,:,:) ))   ! L2 norm
            !        end do
            !    end do

            !    !---Calculate the difference in the L2 norms between iterations 
            !    do f = 1, num_isotopes
            !        do g = 1, num_delay_group
            !            difference_L2 = abs( L2_norm_prev(f,g) - L2_norm_current(f,g) )
            !            if( difference_L2 < nl_iter_tolerance) then
            !                difference_counter = difference_counter + 1
            !            end if
            !        end do
            !    end do
            !    
            !    !---Need to make sure the L2 norm converges for all precursor groups
            !    if ( difference_counter == num_delay_group) then
            !        max_nl_iter = nl_iter - 1 
            !    end if

            !    !---Swap for next iteration
            !    L2_norm_prev = L2_norm_current
            !end if
            
            nl_iter = nl_iter + 1
    
            ! If we've gone thru too many nonlinear iterations exit
             if (nl_iter > max_nl_iter) then
                 exit
             !---If we've gone through a max prescribed and still not converged
             elseif( nl_iter> abs_max_nl_iter) then
                 write(outfile_unit,('(a)')) 'We have gone through the max &
                       iterations andstill not converged, something may be wrong'
                 exit
             end if
        
        end do !---end nonlinear iteration loop
    end if !---end nonlinear if 
    
   
    write(outfile_unit, fmt=('(a)') ) ' ' 
    write(outfile_unit, fmt=('(a, 100I4)')) 'Number of steady state nonlinear iterations: '&
                                            , nl_iter
    write(outfile_unit, fmt=('(a)') ) ' ' 
    
    !---Make the final converged solution the 'previous' solution
    do f = 1, num_isotopes 
        do g = 1, num_delay_group
            do i = 1, num_elem
                do j = 1, nodes_per_elem
                    precursor_soln_prev(f,g,i,j) = precursor_soln_new(f,g,i,j)
                end do
            end do
        end do
    end do
    
    !---Set power 'previous' to new
    precursor_soln_last_time = precursor_soln_new
    
    power_amplitude_prev = power_amplitude_new
    power_amplitude_last_time = power_amplitude_new
    power_soln_prev = power_soln_new
    temperature_soln_prev = temperature_soln_new
    velocity_soln_prev = velocity_soln_new

!---Write precursor solution outfile
    !call write_out_soln(outfile_unit,num_elem,transient_save_flag)

!---Set steady state flag off 
    steady_state_flag = .FALSE.

!---Write to outfile     
    write(outfile_unit, '(a)'), ' '
    write(outfile_unit, '(a)'), '*******************************'
    write(outfile_unit, '(a)'), 'End of Steady state solve'
    write(outfile_unit, '(a)'), '*******************************'

end subroutine steady_state
