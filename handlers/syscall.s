SYSCALL_HANDLER:
    cmp r7, #16
    beq read_sonar
    #cmp r7, #17
    #beq register_proximity_callback
    cmp r7, #18
    beq set_motor_speed
    #cmp r7, #19
    #beq set_motors_speed
    cmp r7, #20
    beq get_time
    #cmp r7, #21
    #beq set_time
    cmp r7, #22
    beq set_alarm
