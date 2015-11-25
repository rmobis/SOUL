set_motors_speed:
    stmfd sp!,{r1-r10}
	@ Checks for invalid speed for motor 0
	cmp r0, #63
	movhi r0, #-1
	bhi set_motors_speed_exit

	@ Checks for invalid speed for motor 1
	cmp r1, #63
	movhi r0, #-2
	bhi set_motors_speed_exit


    ldr r2, =GPIO_BASE @ Base GPIO address
    ldr r3, [r2, #GPIO_DR]

    orr r3, r3, #0x00040000 @ Writes 1 on the write bit
    
    @ Sets Motor0
    bic r3, r3, #0x01F80000
    lsl r0, r0, #19
    eor r3, r3, r0

    @ Sets Motor1
    bic r3, r3, #0xFC000000
    lsl r1, r1, #26
    eor r3, r3, r1

    str r3, [r2, #GPIO_DR]
    bic r3, r3, #0x00040000 @ Writes 0 on the write bit
    str r3, [r2, #GPIO_DR]

    mov r0, #0

set_motors_speed_exit:

	ldmfd sp!,{r1-r10}
    movs pc, lr
