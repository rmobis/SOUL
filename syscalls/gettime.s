get_time:
    ldr r0, =SYS_TIME
    ldr r0, [r0]

    movs pc, lr
