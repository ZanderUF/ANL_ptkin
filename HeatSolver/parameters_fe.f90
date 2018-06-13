module parameters_fe 

    implicit none
 
!---Mesh information
    real, allocatable :: elem_lengths(:) ! length of elements
    integer :: nodes_per_elem ! Nodes per element
    integer :: num_elem ! Number of elements in the mesh
    integer :: max_num_nodes
    integer :: ndf ! ndf
!---Mesh arrays
    integer, allocatable :: conn_matrix(:,:)
    real, allocatable    :: global_coord(:)
!---Elemental matrices
    real, dimension(3,3) :: analytic_heat_elem_matrix_M
    real, dimension(3,3) :: heat_elem_matrix_K
    real, dimension(3,3) :: heat_elem_matrix_M
    real, dimension(3)   :: heat_elem_vector_F
!---Gauss integration 
    integer  :: num_gaus_pts = 4
!---Shape functions, Lagrange, quadratic order
    real, dimension(3) :: shape_fcn
    real, dimension(3) :: der_shape_fcn
    real, dimension(3) :: global_der_shape_fcn 
    real               :: g_jacobian
!---Global matrices
    real, allocatable :: global_heat_matrix_K(:,:)
    real, allocatable :: global_heat_matrix_M(:,:)
    real, allocatable :: cur_elem_soln_vec(:)     ! current solution vector
    real, allocatable :: previous_elem_soln_vec(:)   ! previous solution vector
!---Time information 
    logical :: time_solve       ! decide if we are doing time solve or not  
    real  alpha     ! time solve 
    real  t0        ! starting time
    real  dt        ! time step 
    real  tmax      ! max time 
    real  t_initial ! starting time

!---Initial conditions
    real, allocatable :: initial_conditions(:)
    real ( kind = 8 ) :: T_ic
!---Boundary conditions
    real ( kind = 8 ) :: T_bc
!---Material properties 
    !real, dimension(:)  ( kind = 8 ) conductivity
    !real, dimension(:)  ( kind = 8 ) spec_heat
    !real, dimension(:)  ( kind = 8 ) density

!---File names
    character(60) :: file_name
    integer :: outfile_unit 
    integer :: soln_outfile_unit
!---Nonlinear variables
    integer :: max_iter = 1        ! max num of nonlinear iterations to do
    real :: residual
    real :: tolerance = 0.001 ! prescribed tolerance
    
!---Flags
    logical :: DEBUG = .TRUE.
    
end module parameters_fe 
