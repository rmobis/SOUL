SYSCALL_HANDLER:
    cmp r7, #SYSCALL_RS
    beq read_sonar
    cmp r7, #SYSCALL_RPC
    beq register_proximity_callback
    cmp r7, #SYSCALL_SMS
    beq set_motor_speed
    cmp r7, #SYSCALL_SMSS
    beq set_motors_speed
    cmp r7, #SYSCALL_GT
    beq get_time
    cmp r7, #SYSCALL_ST
    beq set_time
    cmp r7, #SYSCALL_SA
    beq set_alarm
