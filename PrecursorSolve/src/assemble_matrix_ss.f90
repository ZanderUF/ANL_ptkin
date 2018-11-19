!*****************************************************************************80
!
!! Assemble the elemental to solve for coefficients the problem 
!  Discussion:
!             As the elemental matrices are created we add them to the global 
!
!  Input: 
!           isotope - material isotop identifier
!           delay_group - delayed neutron group identifier
!           n - element number
!
!  Output:
! 

subroutine assemble_matrix_ss (isotope,delay_group,n,nl_iter)

    USE element_matrices_M
    USE flags_M
    USE material_info_M
    USE mesh_info_M
    USE global_parameters_M
    USE solution_vectors_M

    implicit none

!---Dummy variables
    integer, intent(in) :: isotope
    integer, intent(in) :: delay_group
    integer, intent(in) :: n
    integer, intent(in) :: nl_iter

!---Local variables
    integer :: i, j, ii, jj, nr,nc, length   
!---Inversion routine parameters
    integer :: lda, info, lwork
    integer,  dimension(3) :: ipiv
    real(dp), dimension(3) :: work

    length = 3
!---Initialize
    ipiv =  0.0_dp
    work =  0.0_dp
    lda =   length
    lwork = length
    
    elem_matrix_G        = 0.0_dp
    elem_vec_w_left_face = 0.0_dp
    elem_vec_q_final     = 0.0_dp

    do i = 1, nodes_per_elem
        !---Calculate q vector
        !if(nl_iter == 1) then
            elem_vec_q_final(isotope,delay_group,i) = &
                  (beta_i_mat(isotope,delay_group)/gen_time)*elem_vec_q(i) 
        !end if

        do j = 1, nodes_per_elem
            if (n > 1) then
                elem_vec_w_left_face(i) = elem_vec_w_left_face(i) + &
                                          matrix_W_left_face(i,j)*&
                                          precursor_soln_new(isotope,delay_group, n-1,3)
            else
                !---First element
                elem_vec_w_left_face(i) = elem_vec_w_left_face(i) + &
                       matrix_W_left_face(i,j)*&
                       precursor_soln_new(isotope,delay_group,num_elem,3)

            end if
            elem_matrix_G(i,j) = -elem_matrix_U(i,j) + &
                       (lamda_i_mat(isotope,delay_group))*elem_matrix_A(i,j) + &
                       matrix_W_right_face(i,j)
        end do
    end do   

!****************************************************************
if(DEBUG .eqv. .TRUE.) then
    write(outfile_unit,fmt='(a)'), ' '
    write(outfile_unit,fmt='(a,4I6)'),'G Matrix | element --> ',n
    do i=1,nodes_per_elem 
          write(outfile_unit,fmt='(12es14.3)') &
               (elem_matrix_G(i,j),j=1,nodes_per_elem)             
    end do
    
    write(outfile_unit,fmt='(a)'), ' ' 
    write(outfile_unit,fmt='(a,4I6)'),'left face vector | element --> ', n
    do j=1,nodes_per_elem 
          write(outfile_unit,fmt='(12es14.3)') elem_vec_w_left_face(j)             
    end do
    
    write(outfile_unit,fmt='(a)'),' '
    write(outfile_unit,fmt='(a,4I6)'),'beta/gen time *{q} element source vector | element --> ',n
    write(outfile_unit,fmt='(12es14.3)') &
         (elem_vec_q_final(isotope,delay_group,i),i=1,nodes_per_elem)             
end if

end subroutine assemble_matrix_ss
