IRQ_HANDLER:
    stmfd sp!, {r0-r10}

    @ Marks the interruption as handled
    ldr r0, =GPT_BASE
    mov r1, #1
    str r1, [r0, #GPT_SR]

    @ Increments system time
    ldr r0, =SYS_TIME
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    @ Checks if there's any alarm scheduled for now
    ldr r2, =prox_alarm
    ldr r3, [r2]
    cmp r3, r1
    bls remove_alarm

irq_end:
    sub lr, lr, #4
    ldmfd sp!, {r0-r10}
    movs pc, lr

remove_alarm:
    @ r4 is the address of the interruption on the interruptions vector
    ldr r4, [r2, #4]
    lsl r4, r4, #3

    @ r6 becoems the address we should jump to after handling the interruption
    ldr r7, =alarms_vector
    add r0, r4, #4
    ldr r6, [r7, r0]

    mov r9, r4
    add r4, r4, #8

    ldr r3, =num_alarms
    ldr r0, [r3]

    @ Removes the value from the alarms vector
loop_vector_removal:
    cmp r4, r0, LSL #3
    bhs search_next_alarm
    ldr r8, [r7, r4]
    str r8, [r7,r9]
    add r4,r4, #4
    add r9,r9, #4
    ldr r8, [r7, r4]
    str r8, [r7, r9]
    add r4,r4, #4
    add r9,r9, #4
    b loop_vector_removal


    @ Looksf or the smallest element inside the alarm vector
search_next_alarm:
    sub r0, r0, #1
    str r0, [r3]

    mov r4, #0
    mvn r8, #1
    mov r3, #0

search_loop:
    cmp r4, r0
    bhs end_search_loop

    ldr r1, [r7, r4, LSL #3]
    cmp r1, r8
    movlo r8, r1
    movlo r3, r4

end_search_loop:

    str r8, [r2]
    str r3, [r2, #4]

    @ branches to the address in r6
    msr CPSR_c, 0x10
    blx r6
    msr CPSR_c, 0x12

    b irq_end
