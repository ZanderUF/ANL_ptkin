! Evalute C_p (thermal conductivity as functino of temperature based on correlation
!
! Correlation is of the form C_p(T) = a + b*T where a, b are constants
! Currently using FliNaK correlation from Rogers (1982)  
! Input:
!       T - temperature to evaluate density at 
! Output:
!       C_p - evaluated conductivity at T
! 
subroutine cond_corr(T, C_p)

implicit none

! Dummy
    real(kind=8), intent(in)  :: T
    real(kind=8), intent(out) :: C_p 
! Local
    real(kind=8) :: a
    real(kind=8) :: b  
    
    a = 9.636 
    b = 10.487
    C_p = a + b*T

end
