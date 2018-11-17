! Initialize the power, temperature, and velocity distributions 
! based on the inputted data
! Input:
!
! Output:
!

subroutine initialize()

    USE global_parameters_M
    USE mesh_info_M
    USE material_info_M
    USE flags_M
    USE solution_vectors_M

implicit none

!---Dummy

!---Local
    integer :: i,jj,j,n
    real(dp) :: ii, elem_length, density, &
                norm_cos, cosine_term, x_last, x_curr,&
                temperature
    real(dp) :: constant_velocity
    logical :: constant_flag
    real(dp) :: inlet_temperature, outlet_temperature
    real(dp) :: fuel_elem_len
        !---Initialize to zero 
    precursor_soln_new(:,:,:,:) = 0.0_dp 
   
    !---Power amplitude set
    power_amplitude_new   = 1.0_dp
    power_amplitude_prev  = power_amplitude_new 
    power_amplitude_start = power_amplitude_new 
    
    steady_state_flag = .TRUE.
     
    !---Initial guesses 
    inlet_temperature = 900.0_dp
    outlet_temperature = 1000.0_dp
    
    !---Test if reading power profile from file or not
        !--TODO

    !---Create spatial power function
    do i = 1, num_elem
        do j = 1, nodes_per_elem
            !---Beginning piping 
            if( i <= Fuel_Inlet_Start )      then
                area_variation(i,j)    = Area_Pipe 
                temperature_soln_new(i,j) = inlet_temperature  
            !---Fuel inlet plenum
            else if ( i <= Fuel_Core_Start)  then
                call Calculate_Plenum_Area(i,j,Area_Plenum)
                area_variation(i,j) = Area_Plenum 
                temperature_soln_new(i,j) = inlet_temperature    
               !---Fuel main core
            else if ( i <= Fuel_Core_End )   then
                area_variation(i,j) = Area_Core
                
                !---linearly interpolate temperature rise over the core
                temperature_soln_new(i,j) = (outlet_temperature - inlet_temperature)/&
                (Fuel_Core_End - Fuel_Core_Start)* &
                (i-Fuel_Core_End ) + &
                outlet_temperature 

                !---Fuel outlet plenum
            else if ( i <= Fuel_Outlet_End ) then
                call Calculate_Plenum_Area(i,j,Area_Plenum)
                area_variation(i,j) = Area_Plenum
                temperature_soln_new(i,j) = outlet_temperature 
            !---External piping
            else 
                area_variation(i,j)    = Area_Pipe
                temperature_soln_new(i,j) = outlet_temperature
            end if
            power_soln_new(i,j) = spatial_power_fcn(i,j)*power_amplitude_new*&
                                  total_power_read_in

            temperature = temperature_soln_new(i,j)
            !---Get density to set the velocity
            call density_corr_msfr(temperature,density)
            density_soln_new(i,j) = density
            !!---Need to get initial velocity distribution
            velocity_soln_new(i,j) = mass_flow/(area_variation(i,j)*density)
        end do
    end do
    
    !---Get the average starting temperature
    total_temperature_initial = 0.0
    Total_Density_Initial = 0.0
    do i = Fuel_Inlet_Start, Fuel_Outlet_End 
        do j = 1, nodes_per_elem
           total_temperature_initial = total_temperature_initial + &
                                             elem_vol_int_fe(j)*temperature_soln_new(i,j) 
            Total_Density_Initial = Total_Density_Initial + &
                                    elem_vol_int_fe(j)*density_soln_new(i,j)
        end do
    end do

    fuel_elem_len =  global_coord(Fuel_Outlet_End,3) -global_coord(Fuel_Inlet_Start,1)
    
    avg_temperature_initial = total_temperature_initial/fuel_elem_len
    Avg_Density_Initial = Total_Density_Initial/fuel_elem_len

    write(outfile_unit,fmt='(a,es23.16)'), 'Average starting temperature is : ',&
                                            avg_temperature_initial
    write(outfile_unit,fmt='(a,es23.16)'), 'Average starting density is : ',&
                                             Avg_Density_Initial
!---
    temperature_soln_prev = temperature_soln_new
    velocity_soln_prev = velocity_soln_new
    density_soln_prev  = density_soln_new
!-------------------------------------------------------------------------------
!---Write out initial solution
    write(outfile_unit,fmt='(a)'), ' '
    write(outfile_unit,fmt='(a)'), 'Initial Spatial Power distribution '
    write(outfile_unit,fmt='(a,12es14.3)'),'Initial power amplitude', power_amplitude_new
    write(outfile_unit,fmt='(a)'), 'Position(x) Power [n/cm^3*s]'
    write(outfile_unit,fmt='(a)'), '------------------------------------'
    do i = 1,num_elem
        do j = 1, nodes_per_elem
            write(outfile_unit, fmt='(12es14.3, 12es14.3)')  global_coord(i,j), power_soln_new(i,j)
        end do
    end do
!-------------------------------------------------------------------------------
!---Write out initial solution
    write(outfile_unit,fmt='(a)'), ' '
    write(outfile_unit,fmt='(a)'), 'Initial temperature distribution '
    write(outfile_unit,fmt='(a)'), 'Position(x) Temperature [K]'
    write(outfile_unit,fmt='(a)'), '------------------------------------'
    do i = 1, num_elem 
        do j = 1, nodes_per_elem
            write(outfile_unit, fmt='(12es14.3, 12es14.3)')  global_coord(i,j), temperature_soln_new(i,j)
        end do
    end do
!---Write out initial solution
    write(outfile_unit,fmt='(a)'), ' '
    write(outfile_unit,fmt='(a)'), 'Initial velocity distribution '
    write(outfile_unit,fmt='(a)'), 'Position(x) Velocity [cm/s]'
    write(outfile_unit,fmt='(a)'), '------------------------------------'
    do i = 1, num_elem 
        do j = 1, nodes_per_elem
            write(outfile_unit, fmt='(12es14.3, 12es14.3)')  global_coord(i,j), velocity_soln_new(i,j)
        end do 
    end do
    !---Write out initial solution
    write(outfile_unit,fmt='(a)'), ' '
    write(outfile_unit,fmt='(a)'), 'Initial density distribition '
    write(outfile_unit,fmt='(a)'), 'Position(x) Density [g/cm^3]'
    write(outfile_unit,fmt='(a)'), '------------------------------------'
    do i = 1, num_elem 
        do j = 1, nodes_per_elem
            write(outfile_unit, fmt='(12es14.3, 12es14.3)')  global_coord(i,j), density_soln_new(i,j)
        end do
    end do
    
end subroutine

!-------
! This calculates the cross sectional area as the inlet/outlet plenum
! increases or decreases
subroutine Calculate_Plenum_Area(i,j,area)
    
    USE global_parameters_M
    USE mesh_info_M

    implicit none
   
!---Dummy
    integer, intent(in)  :: i  !- element 
    integer, intent(in)  :: j  !- node
    real(dp),intent(out) :: area 
!---Local
    real(dp) :: area_1, area_2

!---Increasing area
    if ( i <= Fuel_Core_Start ) then
         area_1 = ( (0.5_dp*( Area_Core - Area_Pipe ) ) / &
                    ( global_coord(Fuel_Core_Start, 3) - &
                      global_coord(Fuel_Inlet_Start,1) ) )* &
                      ( global_coord(i,j) - global_coord(Fuel_Inlet_Start,1) ) + &
                         0.5_dp*Area_Pipe  
         area_2 = ( (0.5_dp*( Area_Pipe - Area_Core )) / &
                    ( global_coord(Fuel_Core_Start, 3) - &
                      global_coord(Fuel_Inlet_Start,1) )*  &
                     ( global_coord(i,j) - global_coord(Fuel_Inlet_Start,1) ) - &
                      0.5_dp*Area_Pipe )
         area = area_1 - area_2
    else
!---Decreasing area
        area_1 = ( (0.5_dp*( Area_Core - Area_Pipe ) ) / &
                    ( global_coord(Fuel_Core_End, 3) - &
                      global_coord(Fuel_Outlet_End,1) ) ) * &
                      (global_coord(i,j) - global_coord(Fuel_Outlet_End,j)) + &
                      0.5_dp*Area_Pipe  

         area_2 = ( (0.5_dp*( Area_Pipe - Area_Core )) / &
                    ( global_coord(Fuel_Core_End, 3) - &
                      global_coord(Fuel_Outlet_End,1) )) * &
                      (global_coord(i,j) - global_coord(Fuel_Outlet_End,j)) - &
                        0.5_dp*Area_Pipe 
         area = area_1 - area_2
        
    end if


end subroutine 

!------------------------------------------------------------------
subroutine get_norm_coord(i,j,norm_cos)
    
    USE global_parameters_M
    USE mesh_info_M

    implicit none
    
!---Dummy
    integer, intent(in) :: i
    integer, intent(in) :: j
    real(dp),    intent(out) :: norm_cos

!---Local
    real :: x_curr, x_last

!---Get curren global coordinate
    x_curr =   global_coord(i,j) 
    !---Last global coordinate
    x_last =  global_coord(Fuel_Outlet_End,3)
    !---Normalize coordinates so we go from -1 to 1
    norm_cos = ( (x_curr) - (x_last*0.5) )/ (Fuel_Outlet_End - Fuel_Inlet_Start)

end subroutine get_norm_coord
