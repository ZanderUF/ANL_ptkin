!*****************************************************************************80
!
!! Main subroutine for the solve 

subroutine driver_solve ( )

    USE flags_M
    USE global_parameters_M
    USE datainput_fe_M
    USE mesh_info_M
    USE material_info_M
    USE time_info_M
    USE solution_vectors_M

implicit none

!---Dummy

!---Local
    integer  ::  i,j, n  
    character(len=80) :: current_path
    character(len=20) :: outfile_name
    character(len=21) :: steady_state_soln_file_name
    character(len=20) :: last_time_file_name
    character(len=20) :: power_soln_file_name
    character(len=7)  :: input_file
    character(len=20) :: beta_special_name
    character(len=18) ::nl_out_name

    real(dp) :: start, finish

!---Name the files to write out something sensible

    outfile_name                = 'outfile.txt'
    steady_state_soln_file_name = 'ss_precursor_soln.txt'
    last_time_file_name         = 'last_t_soln.txt'
    power_soln_file_name        = 'power_amp_soln.txt'
    input_file                  = 'input_t'
    beta_special_name           = 'beta_flowspeed.txt'
    nl_out_name                 = 'nl_conv_info.txt'

!---Open file for writing out debug information
    open (unit=outfile_unit, file=outfile_name,status='unknown',&
    	  form='formatted',position='asis')
    open (unit=soln_outfile_unit, file=steady_state_soln_file_name,&
    	  status='unknown',form='formatted',position='asis')
    open (unit=power_outfile_unit, file=power_soln_file_name,&
    	  status='unknown',form='formatted',position='asis')
    open (unit=beta_special_unit, file=beta_special_name,&
    	  status='unknown',form='formatted',position='asis')
    open (unit=nl_outfile_unit, file=nl_out_name,&
    	  status='unknown',form='formatted',position='asis')

!---Read in problem parameters here
    call datainput_fe(input_file)

    call write_out_parms()
    
!---Allocate solution vector and global matrices
    allocate(precursor_soln_new(num_isotopes,num_delay_group,num_elem,nodes_per_elem),  &
             power_soln_new(num_elem,nodes_per_elem), &
             temperature_soln_new( num_elem,nodes_per_elem),  &
             density_soln_new( num_elem,nodes_per_elem),  &
             velocity_soln_new( num_elem,nodes_per_elem),  &
             precursor_soln_prev(num_isotopes,num_delay_group,num_elem,nodes_per_elem), &
             power_soln_prev(num_elem,nodes_per_elem), &
             temperature_soln_prev( num_elem,nodes_per_elem), &
             density_soln_prev( num_elem,nodes_per_elem),  &
             velocity_soln_prev( num_elem,nodes_per_elem), &
             spatial_power_fcn( num_elem, nodes_per_elem), &
             spatial_doppler_fcn(num_elem, nodes_per_elem), &
             spatial_expansion_fcn(num_elem, nodes_per_elem), &
             elem_vec_q_final(num_isotopes,num_delay_group,nodes_per_elem),& 
             elem_vol_int(num_elem,nodes_per_elem),&
             precursor_soln_last_time(num_isotopes,num_delay_group,num_elem,nodes_per_elem),&
             power_soln_last_time(num_elem,nodes_per_elem),& 
             area_variation(num_elem,nodes_per_elem), & 
             density_soln_starting(num_elem,nodes_per_elem), &
             temperature_soln_starting(num_elem,nodes_per_elem), &
             power_soln_starting(num_elem,nodes_per_elem), &
             Density_Reactivity_Feedback(num_elem,nodes_per_elem), &
             Temperature_Reactivity_Feedback(num_elem,nodes_per_elem) )

allocate(beta_initial_vec(num_isotopes,num_delay_group))
allocate(beta_j(num_isotopes,num_delay_group), &
         beta_j_minus_1(num_isotopes,num_delay_group),&
         beta_j_plus_1(num_isotopes,num_delay_group) )
allocate(beta_change_all_previous(num_isotopes,num_delay_group),&
         beta_change(num_isotopes,num_delay_group))

allocate(beta_correction_vec(num_isotopes,num_delay_group))
allocate(residual(num_isotopes,num_delay_group,num_elem,nodes_per_elem))

beta_change_all_previous(:,:) = 0.0_dp
        beta_change(:,:) = 0.0_dp
!---Create 1D mesh
    call mesh_creation
    
    if(Read_DIF3D .eqv. .TRUE.) then
        call read_power
        call read_beta_flow
    end if

    call cpu_time(start)
!---Steady state solve for temperature 
    call steady_state
    
    print *, 'Finished Steady State'

!---Time dependent calculation
    if(time_solve .eqv. .TRUE. ) then
        
        if( td_method_type == 0) then
            write(outfile_unit, fmt=('(a)')) ' '
            write(outfile_unit, fmt=('(a)')) 'Performing forward Euler time integration' 
        end if
        
        if( td_method_type == 1) then
            write(outfile_unit, fmt=('(a)')) ' '
            write(outfile_unit, fmt=('(a)')) 'Performing backward Euler time integration'
        end if    
        
        call transient_euler
    
    end if

    !---Print timing information
    call cpu_time(finish)
    
    write(outfile_unit, fmt=('(a,es16.4,a)')) 'Calculation time = ',finish-start , ' seconds' 

 deallocate(precursor_soln_new, &
            power_soln_new, &
            temperature_soln_new, &
            density_soln_new, &
            velocity_soln_new, &
            precursor_soln_prev, &
            power_soln_prev, &
            temperature_soln_prev, &
            density_soln_prev, &
            velocity_soln_prev, &
            spatial_power_fcn, &
            elem_vec_q_final, & 
            elem_vol_int, &
            precursor_soln_last_time, &
            power_soln_last_time, & 
            area_variation )
   
!---Close units
   close(outfile_unit)
   close(soln_outfile_unit)
   close(power_outfile_unit)

end subroutine driver_solve 
