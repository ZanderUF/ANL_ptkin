module solution_vectors_M

    USE global_parameters_M 
   
    implicit none

!---real(dp)tion matrices - global

    real(dp) , allocatable :: TimeAll(:)
    real(dp) , allocatable :: PowerAllTime(:)
    real(dp) , allocatable :: RhoInsertedAll(:)
    real(dp) , allocatable :: DopplerFeedbackAll(:)
    real(dp) , allocatable :: DensityFeedbackAll(:)
    real(dp) , allocatable :: MassFlowAll(:)
    real(dp) , allocatable :: TempHeatExchangerAll(:)
    real(dp) , allocatable :: AvgTempAll(:)
    real(dp) , allocatable :: PeakTempAll(:)
    real(dp) , allocatable :: NonLinearIterAll(:)

    real(dp) , allocatable :: precursor_soln_last_time(:,:,:,:)
    real(dp) , allocatable :: power_soln_last_time(:,:)

    real(dp) , allocatable :: residual(:,:,:,:)
    real(dp) , allocatable :: elem_vec_q_final(:,:,:) 
    real(dp) , allocatable :: elem_vol_int(:,:)
    real(dp) , allocatable :: precursor_soln_new(:,:,:,:) ! isotope,group,node,value
    real(dp) , allocatable :: power_soln_new(:,:)
    real(dp) , allocatable :: temperature_soln_new(:,:)
    real(dp) , allocatable :: density_soln_new(:,:)
    real(dp) , allocatable :: velocity_soln_new(:,:)
    real(dp) , allocatable :: density_soln_starting(:,:)
    real(dp) , allocatable :: temperature_soln_starting(:,:)
    real(dp) , allocatable :: power_soln_starting(:,:)

    real(dp) , allocatable :: precursor_soln_prev(:,:,:,:)! isotope,group,node,value
    real(dp) , allocatable :: power_soln_prev(:,:)
    real(dp) , allocatable :: temperature_soln_prev(:,:)
    real(dp) , allocatable :: density_soln_prev(:,:)
    real(dp) , allocatable :: velocity_soln_prev(:,:) 
    real(dp) , allocatable :: density_soln_ss(:,:)
    real(dp) , allocatable :: temperature_soln_ss(:,:)
   
    !---L2 norms
    real(dp), allocatable :: L2_prev_precursors(:,:)
    real(dp), allocatable :: L2_current_precursors(:,:)
    real(dp), allocatable :: L2_diffs_precursors(:,:) 
    
    real(dp) :: L2_current_temperature 
    real(dp) :: L2_prev_temperature
    real(dp) :: L2_diffs_temperature 
    !---Spatially varying values read in from DIF3D    
    real(dp) , allocatable :: spatial_vol_fcn(:,:)
    real(dp) , allocatable :: spatial_area_fcn(:,:)
    real(dp) , allocatable :: spatial_power_fcn(:,:)
    real(dp) , allocatable :: spatial_power_frac_fcn(:,:)
    real(dp) , allocatable :: spatial_doppler_fcn(:,:)
    real(dp) , allocatable :: spatial_expansion_fcn(:,:)

    real(dp) , allocatable :: Density_Reactivity_Feedback(:)
    real(dp) , allocatable :: Temperature_Reactivity_Feedback(:,:)

    real(dp) , allocatable :: cur_elem_soln_vec(:,:)       ! current solution vector
    real(dp) , allocatable :: previous_elem_soln_vec(:,:)  ! previous solution vector

    real(dp) , allocatable :: dif3d_volume_input(:) 
    real(dp) , allocatable :: dif3d_area_input(:)
    real(dp) , allocatable :: dif3d_axial_input(:)
    real(dp) , allocatable :: dif3d_power_frac_input(:)
    real(dp) , allocatable :: dif3d_power_input(:)
    real(dp) , allocatable :: dif3d_doppler_input(:)
    real(dp) , allocatable :: dif3d_expansion_input(:)

    real(dp) :: total_power_read_in
    real(dp) :: total_power_fraction
    
    real(dp) :: power_amplitude_last_time
    real(dp) :: power_amplitude_start
    real(dp) :: power_amplitude_prev
    real(dp) :: power_amplitude_new
    
    real(dp) :: avg_temperature_initial
    real(dp) :: Avg_Density_Initial
    real(dp) :: total_temperature_initial
    real(dp) :: Total_Density_Initial
    real(dp) :: average_temperature_ss 
    real(dp) :: average_density_ss
    
    real(dp) :: average_temperature
    real(dp) :: peak_temperature

    real(dp) :: total_power_prev
    real(dp) :: total_power_initial
    real(dp) :: center_power_initial

    real , dimension(3)   :: A_times_W_times_upwind_elem_vec

    real(dp) , dimension(3)   :: elem_matrix_A_times_W_RHS
    real(dp) , dimension(3)   :: elem_vec_A_times_q
    real(dp) , dimension(3,3)   :: A_times_W_times_RHS_elem_vec
    real(dp) , dimension(3)   :: elem_vec_w_left_face
    real(dp) , dimension(3)   :: elem_vec_v
    real(dp) , dimension(3)   :: Pu_minus_flux_vec
    real(dp) , dimension(3)   :: elem_vec_f 
    real(dp) , dimension(3)   :: elem_vec_Pu
    real(dp) , dimension(3)   :: elem1_vec_M_s1 
    real(dp) , dimension(3)   :: last_elem_vec_M_s2
    real(dp) , dimension(3)   :: elem1_vec_f
    real(dp) , dimension(3)   :: last_elem_vec_f
    real(dp) , dimension(3)   :: elem_vec_q
    real(dp) , dimension(3)    :: RHS_transient_final_vec

end module solution_vectors_M
