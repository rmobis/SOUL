set_motor_speed:
    cmp r1, #63
    bhi quit
    cmp r0, #0
    beq set_motor0
    cmp r0, #1
    beq set_motor1
    mov r0, #-1
    movs pc, lr
quit:
    mov r0, #-2
    movs pc, lr


set_motor0:
    stmfd sp!,{r1-r10}

    ldr r2, =GPIO_BASE @ Base GPIO address
    ldr r3, [r2, #GPIO_DR]

    orr r3, r3, #0x00040000 @ Writes 1 on the write bit
    bic r3, r3, #0x01F80000
    lsl r1, r1, #19
    eor r3, r3, r1

    str r3, [r2, #GPIO_DR]

    bic r3, r3, #0x00040000 @ Writes 0 on the write bit

    str r3, [r2, #GPIO_DR]

    mov r0, #0

    ldmfd sp!, {r1-r10}
    movs pc, lr

set_motor1:
    stmfd sp!, {r1-r10}

    ldr r2, =GPIO_BASE @ Base GPIO address
    ldr r3, [r2, #GPIO_DR]

    orr r3, r3, #0x02000000 @ Writes 1 on the write bit
    bic r3, r3, #0xFC000000
    lsl r1, r1, #26
    eor r3, r3, r1

    str r3, [r2]

    bic r3, r3, #0x02000000 @ Writes 0 on the write bit

    str r3, [r2]

    mov r0, #0

return:
    ldmfd sp!, {r1-r10}
    movs pc, lr
