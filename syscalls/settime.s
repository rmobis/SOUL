set_time:
    ldr r1, =SYS_TIME
    str r0, [r1]

    movs pc, lr
