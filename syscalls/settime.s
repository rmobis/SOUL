set_time:
    stmfd sp!, {r1}
    ldr r1, =SYS_TIME
    str r0, [r1]

    ldmfd sp!, {r1}
    movs pc, lr
