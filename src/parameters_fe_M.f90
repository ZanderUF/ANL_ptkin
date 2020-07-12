module parameters_fe 

    implicit none

!---Gauss pts
    double precision , dimension(4)  :: gauspt, gauswt
    data gauspt /-0.8611363116, -0.3399810435, 0.3399810435, 0.8611363116 /  
    data gauswt / 0.347854851 ,  0.6521451548, 0.6521451548, 0.347854851 /
    !integer, parameter :: dp = selected_real_kind(14)

!---Mesh information
    !real , allocatable :: elem_lengths(:) ! length of elements
    !real , allocatable :: elem_node_lengths(:)
    !integer  :: nodes_per_elem ! Nodes per element
    !integer  :: num_elem ! Number of elements in the mesh
    !integer  :: max_num_nodes
    !integer  :: ndf ! ndf
    !integer  :: matrix_length
    !real     :: elem_size
    !integer  :: non_fuel_start
    !real     :: mass_elem ! mass per element
    !real :: area_core, area_pipe
    !
    !real     :: total_power_prev
    !integer  :: num_elem_external
    !real     :: total_power_initial
    !real     :: center_power_initial
    !real     :: cos_tot
    !
!---!Mesh arrays
    !integer, allocatable  :: conn_matrix(:,:)
    !real , allocatable    :: global_coord(:,:)
    !real, allocatable :: power_soln_test(:)
    !real, allocatable :: area_variation(:,:)
    !integer :: fuel_region_start
    !
!---!Elemental matrices
    !double precision , dimension(3,3) :: elem_matrix_A_times_W
    !double precision , dimension(3,3) :: identity_matrix
    !double precision , dimension(3,3) :: inverse_A_matrix
    !double precision , dimension(3,3) :: analytic_elem_matrix_P_ss
    !double precision , dimension(3,3) :: analytic_elem_matrix_A
    !double precision , dimension(3,3) :: elem_matrix_U
    !double precision , dimension(3,3) :: elem_matrix_A
    !double precision , dimension(3,3) :: elem_matrix_G
    !double precision , dimension(3,3) :: elem_matrix_F
    !double precision , dimension(3,3) :: elem_matrix_H
    !double precision , dimension(3,3) :: matrix_W_left_face
    !double precision , dimension(3,3) :: matrix_W_right_face
    !double precision , dimension(3)   :: interp_fcn_rhs, interp_fcn_lhs
    !data interp_fcn_lhs / 1,0,0/
    !data interp_fcn_rhs / 0,0,1/
    !data identity_matrix /1,0,0,&
    !                     0,1,0,&
    !                     0,0,1/
    !double precision :: g_jacobian 
    !double precision , dimension(3)   :: elem_matrix_A_times_W_RHS
    !double precision , dimension(3)   :: elem_vec_A_times_q
    !double precision , dimension(3)   :: A_times_W_times_upwind_elem_vec 
    !double precision , dimension(3,3) :: A_times_W_times_RHS_elem_vec
    double precision , dimension(3)   :: H_times_soln_vec
    !double precision , dimension(3)   :: elem_vec_w_left_face
    !double precision , dimension(3)   :: elem_vec_v
    !double precision , dimension(3)   :: Pu_minus_flux_vec
    !double precision , dimension(3)   :: elem_vec_f 
    !double precision , dimension(3)   :: elem_vec_Pu
    !double precision , dimension(3)   :: elem1_vec_M_s1 
    !double precision , dimension(3)   :: last_elem_vec_M_s2
    !double precision , dimension(3)   :: elem1_vec_f
    !double precision , dimension(3)   :: last_elem_vec_f
    !double precision , dimension(3)   :: elem_vec_q
    !
    !double precision, dimension(3)    :: RHS_transient_final_vec
    !
!---!Gauss integration 
    !integer  :: num_gaus_pts = 4
!---!Shape functions, Lagrange, quadratic order
    !double precision , dimension(3) :: shape_fcn
    !double precision , dimension(3) :: der_shape_fcn
    !double precision , dimension(3) :: global_der_shape_fcn 
    !
!---!double precisiontion matrices - global
    !
    !double precision , allocatable :: precursor_soln_last_time(:,:,:,:)
    !double precision , allocatable :: power_soln_last_time(:,:)
    !
    !double precision , allocatable :: elem_vec_q_final(:,:,:) 
    !double precision , allocatable :: elem_vol_int(:,:)
    !double precision , allocatable :: precursor_soln_new(:,:,:,:) ! isotope,group,node,value
    !double precision , allocatable :: power_soln_new(:,:)
    !double precision , allocatable :: temperature_soln_new(:,:)
    !double precision , allocatable :: density_soln_new(:,:)
    !double precision , allocatable :: velocity_soln_new(:,:)
    !
    !double precision , allocatable :: precursor_soln_prev(:,:,:,:)! isotope,group,node,value
    !double precision , allocatable :: power_soln_prev(:,:)
    !double precision , allocatable :: temperature_soln_prev(:,:)
    !double precision , allocatable :: density_soln_prev(:,:)
    !double precision , allocatable :: velocity_soln_prev(:,:) 
    !double precision , allocatable :: spatial_power_fcn(:,:)
    !double precision , allocatable :: cur_elem_soln_vec(:,:)       ! current solution vector
    !double precision , allocatable :: previous_elem_soln_vec(:,:)  ! previous solution vector
    !
!---!Time information 
    !logical :: time_solve       ! decide if we are doing time solve or not  
    !real   alpha     ! time solve 
    !double precision   t0        ! starting time
    !double precision   delta_t        ! time step 
    !double precision   tmax      ! max time 
    !double precision   t_initial ! starting time
    !
    !double precision :: power_amplitude_last_time
    !double precision :: power_amplitude_start
    !double precision :: power_amplitude_prev
    !double precision :: power_amplitude_new
    !
    !double precision :: reactivity = 0.0
    !double precision :: reactivity_input = 0.0
!---!Material
    !!real, dimension(:)  ( kind = 8 ) conductivity
    !!real, dimension(:)  ( kind = 8 ) spec_heat
    !!real, dimension(:)  ( kind = 8 ) density
    !double precision :: beta_correction
    !real, allocatable  :: lamda_i_mat(:,:)
    !real, allocatable  :: beta_i_mat(:,:)
    !double precision     :: gen_time
    !double precision     :: mass_flow
    !integer  :: num_isotopes
    !integer  :: num_delay_group
    !
!---!File names
    !character(60) :: file_name
    !integer :: outfile_unit = 15 
    !integer :: soln_outfile_unit = 99
    !integer :: soln_last_t_unit = 66
    !integer :: power_outfile_unit = 20
!---!Nonlinear variables
    !integer :: max_iter = 1 ! max num of nonlinear iterations to do
    !integer :: max_nl_iter  ! numer of nonllinear iterations to do
    !real :: residual
    !real :: tolerance = 0.001 ! prescribed tolerance
    !
    !real :: avg_temperature_initial
    !real :: total_temperature_initial
    !
    !real :: reactivity_feedback
!---Flags
    !integer :: feedback_method = 0
    !real :: save_time_interval
    !integer :: td_method_type = 0
    !logical :: DEBUG = .FALSE.
    !logical :: steady_state_flag = .TRUE.    
    !logical :: unit_test = .FALSE. 
    !logical :: unit_test_2 = .FALSE. 
    !logical :: nonlinear_ss_flag 
    !logical :: lagrange = .FALSE.
    !logical :: hermite = .TRUE.
    !logical :: transient
    !logical :: transient_save_flag = .FALSE. 
    !logical :: ramp_flag = .FALSE.
    !logical :: step_flag = .FALSE.
    !logical :: zag_flag = .FALSE.
    !
end module parameters_fe 
