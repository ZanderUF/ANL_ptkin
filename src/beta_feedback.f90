!---Beta feedback

subroutine beta_feedback

    USE flags_M
    USE global_parameters_M
    USE solution_vectors_M
    USE time_info_M
    USE mesh_info_M
    USE material_info_M

    implicit none

    integer  :: event_counter
    logical  :: event_occuring 
    real(dp) :: event_start_time, event_time,event_time_previous, t1
    
    event_start_time = delta_t 

   !---Evaluate if
    if(feedback_method == 2 ) then
        !---Logic for evaluating beta over time
        !---This determines the first 'event' time for the whole transient
        if( t0 == event_start_time) then
            event_counter = 1
            event_time = event_start_time 
            event_time_previous = event_start_time - delta_t 
            event_occuring = .TRUE.
        end if 
        
        if(t0 >= event_start_time) then
            !---Very the flow rate with time
            if(event_occuring .eqv. .TRUE.) then
                mass_flow = mass_flow_initial*exp(time_constant*t0)
            end if
            !---Evaluate pump coast down 
            !---Stop after get to 80% of starting flow rate
            if( mass_flow > 0.75*mass_flow_initial) then
               
                !--Event counter = 2 --> instant | 1 --> lagged
                event_counter = 1    
                
                End_Event = .FALSE. 
                event_occuring = .TRUE.
            
                call evaluate_beta_change(event_time, event_time_previous, &
                                          event_counter, event_occuring)
                
                event_time          = t0  
                event_time_previous = event_time - delta_t
            else
                !---No more 'event's happening so this is the last event time
                event_counter = 1 
                event_occuring = .FALSE.
                call evaluate_beta_change(event_time,event_time_previous,&
                                          event_counter,event_occuring)
            end if
    
        end if 
    end if

    if(feedback_method == 3) then 
        !---Slow down the mass flow rate
        if(flow_reduction_percent < 1.0) then
            
            !if(mass_flow > flow_reduction_percent*mass_flow_initial) then
            !    mass_flow = mass_flow_initial*exp(time_constant*t0)
            !end if
        else 
        !---Increase the mass flow rate
            if(mass_flow < flow_reduction_percent*mass_flow_initial) then
                mass_flow =  mass_flow_initial + (flow_reduction_percent - 1.0)*mass_flow_initial*(1.0 -exp(time_constant*t0) )
            end if
        end if
    end if

end subroutine beta_feedback
