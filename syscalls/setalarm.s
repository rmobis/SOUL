set_alarm:
    stmfd sp!, {r1-r10}

    @ Checks the number of active alarms
    ldr r2, =num_alarms
    ldr r3, [r2]
    cmp r3, #MAX_ALARMS
    blo alarm_overflow

    @ Checks if the time is lower than system time
    ldr r4, =SYS_TIME
    ldr r4, [r4]
    cmp r4, r1
    bls too_soon

    @ Writes alarm to the end of alarms vector
    lsl r3, r3, #3
    add r4, r3, #alarms_vector
    str r1, [r4]
    str r0, [r4, #4]

    @ Updates next alarm, if needed
    ldr r5, =prox_alarm
    ldr r6, [r5]
    cmp r1, r6
    strlo r1, [r5]
    strlo r3, [r5, #4]

    @ Increments the alarm counter
    add r3, r3, #1
    str r3, [r2]

fim_setalarm:
    ldmfd sp!, {r1-r10}
    movs pc, lr

alarm_overflow:
    mov r0, #-1
    b fim_setalarm

too_soon:
    mov r0, #-2
    b fim_setalarm
