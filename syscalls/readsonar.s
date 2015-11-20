read_sonar:
    stmfd sp!, {r1-r10}

    ldr r2, =GPIO_BASE @ Base GPIO address
    ldr r1, [r2, #GPIO_DR]

    bic r1, r1, #0x0000003C @ Mask for SONAR_MUX bits
    lsl r0, r0, #2
    and r0, r0, #0x0000003C
    eor r1, r1, r0

    @ Sonar_mux <= sonar_id
    str r1, [r2, #GPIO_DR]


    @ Trigger <= 0
    bic r1, r1, #0x00000002
    str r1, [r2, #GPIO_DR]

    @ Delay 15ms
    mov r3, #SYS_TIME
    ldr r4, [r3] @ Loads system time
    add r4, r4, #15

loop_timer:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer


    @ Trigger <= 1
    eor r1, r1, #0x00000002
    str r1, [r2, #GPIO_DR]

    @ Delay 15ms
    ldr r4, [r3] @ Loads system time
    add r4, r4, #15

loop_timer2:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer2

    @ Trigger <= 0
    bic r1, r1, #0x00000002
    str r1, [r2, #GPIO_DR]

testa_flag:
    @ FLAG == 1?
    ldr r1, [r2, #GPIO_PSR]
    bic r1, r1, #0xFFFFFFFE

    cmp r1, #1
    beq fim_readsonar

    @ Delay 10ms
    ldr r4, [r3] @ Loads system time
    add r4, r4, #10

loop_timer3:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer3

    b testa_flag


fim_readsonar:
    ldr r1, [r2, #GPIO_PSR]
    ldr r3, =0xFFFC0000
    bic r1, r1, r3
    lsr r1, r1, #6

    mov r1, r0

    ldmfd sp!, {r1-r10}
    movs pc, lr

