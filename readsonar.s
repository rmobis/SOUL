read_sonar:
    stmfd sp, {r1-r10}

    mov r2, #DR @ Endereço do registrador de dados da GPIO
    ldr r1, [r2]

    bic r1, r1, #0x0000003C @ Máscara para os bits do SONAR_MUX
    lsl r0, r0, #2
    and r0, r0, #0x0000003C
    eor r1, r1, r0
    
    @ Sonar_mux <= sonar_id
    str r1,[r2] 


    @ Trigger <= 0
    bic r1, r1,#0x00000002
    str r1,[r2] 

    @ Delay 15ms
    mov r3, SYS_TIME
    ldr r4, [r3] @ carrega o tempo do sistema
    add r4, r4, #15

loop_timer:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer


    @ Trigger <= 1
    eor r1, r1, #0x00000002
    str r1,[r2] 

    @ Delay 15ms
    ldr r4, [r3] @ carrega o tempo do sistema
    add r4, r4, #15

loop_timer2:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer2

    @ Trigger <= 0
    bic r1, r1,#0x00000002
    str r1,[r2] 

    mov r2, #PSR @ Endereço do registrador de dados da GPIO
testa_flag:
    @ FLAG == 1?
    ldr r1, [r2] 
    bic r1, r1, #0xFFFFFFFE

    cmp r1, #1
    beq fim_readsonar

    @ Delay 10ms
    ldr r4, [r3] @ carrega o tempo do sistema
    add r4, r4, #10

loop_timer3:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer3

    b testa_flag 


fim_readsonar:
    ldr r1, [r2] 
    bic r1, r1, #0xFFFC0000
    lsr r1, r1, #6

    mov r1, r0

    ldmfd sp, {r1-r10}
    movs pc, lr
 
