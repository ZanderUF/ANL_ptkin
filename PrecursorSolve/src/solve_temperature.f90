! Solves for the temperature at a time step
!
! Input: n - element number
! 
! Output: 
!

subroutine solve_temperature(n)

    USE flags_M
    USE material_info_M
    USE mesh_info_M
    USE time_info_M
    USE global_parameters_M
    USE solution_vectors_M
    USE element_matrices_M


implicit none

!---Dummy
    integer, intent(in) :: n 

!---Local
    integer :: j
    real(dp) :: temperature_eval, heat_capacity_eval

!---Loop over all nodes in an element
    do j = 1, nodes_per_elem
        !---Get thermal heat_capacity value
        temperature_eval = temperature_soln_prev(n,j)
        call heat_capacity_corr(temperature_eval, heat_capacity_eval)
        
        !---This should work for forward Euler
        temperature_soln_new(n,j) = ( (power_soln_prev(n,j) - &
                                       power_soln_starting(n,j) ) &
                                    /( (mass_flow*heat_capacity_eval) )) &
                                    + temperature_soln_prev(n,j) 
        
        !---Calculate doppler feedback for current element 
        Temperature_Reactivity_Feedback(n,j) = spatial_doppler_fcn(n,j)* &
                    (temperature_soln_starting(n,j) - temperature_soln_prev(n,j)  )

    end do
    
end subroutine solve_temperature
