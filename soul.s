@ vim:ft=armv5
.set TIME_SZ 200000
.org 0x0
.section .iv,"a"

_start:		

interrupt_vector:

    b RESET_HANDLER
.org 0x08
    b SYSCALL_HANDLER
.org 0x18
    b IRQ_HANDLER



.org 0x100
.text

    @ Zera o contador
    ldr r2, =SYS_TIME  @lembre-se de declarar esse contador em uma secao de dados! 
    mov r0,#0
    str r0,[r2]

RESET_HANDLER:

    @Set interrupt table base address on coprocessor 15.
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    ldr r0, =0x53FA0000
    ldr r1, =0x41
    str r1,[r0] 

    ldr r0, =0x53FA0004 
    ldr r1, =0x0
    str r1, [r0]

    ldr r0, =0x53FA0010 
    ldr r1, =TIME_SZ
    str r1, [r0]

    ldr r0, =0x53FA000c 
    ldr r1, =1
    str r1, [r0]



SET_TZIC:
    @ Constantes para os enderecos do TZIC
    .set TZIC_BASE,             0x0FFFC000
    .set TZIC_INTCTRL,          0x0
    .set TZIC_INTSEC1,          0x84 
    .set TZIC_ENSET1,           0x104
    .set TZIC_PRIOMASK,         0xC
    .set TZIC_PRIORITY9,        0x424

    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE

    ldr	r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)

    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]

    @instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled

    @Configura GPIO
    mov r0, #0x53F84004

    @ Ta serto?
    mov r1, #2_11111111111111000000000000111110
    str r1, [r0]

    @ Como vou transferir pra main do código em C??


IRQ_HANDLER:
    ldr r0, =0x53FA0008 
    ldr r1, =1
    str r1, [r0]

    ldr r0,=SYS_TIME
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    sub lr, lr, 4

    movs pc, lr

SYSCALL_HANDLER:
    cmp r7, #16
    beq read_sonar
    cmp r7, #17
    beq register_proximity_callback
    cmp r7, #18
    beq set_motor_speed
    cmp r7, #19
    beq set_motors_speed
    cmp r7, #20
    beq get_time
    cmp r7, #21
    beq set_time
    cmp r7, #22
    beq set_alarm

read_sonar:
    stmfd sp, {r1-r10}

    mov r2, #0x53F84000 @ Endereço do registrador de dados da GPIO
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

testa_flag:
    @ FLAG == 1?
    ldr r1, [r2] 
    bic r1, r1, #0xFFFFFFFE

    cmp r1, #1
    beq fim

    @ Delay 10ms
    ldr r4, [r3] @ carrega o tempo do sistema
    add r4, r4, #10

loop_timer3:
    ldr r5, [r3]
    cmp r5, r4
    bls loop_timer3

    b testa_flag 


fim:
    ldr r1, [r2] 
    bic r1, r1, #0xFFFC0000
    lsr r1, r1, #6

    mov r1, r0

    ldmfd sp, {r1-r10}
    movs pc, lr
    
@ /read_sonar

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
    stmfd sp, {r1-r10}

    mov r2, #0x53F84000 @ Endereço do registrador de dados da GPIO
    ldr r3, [r2]

    orr r3, r3, #0x00040000 @ Escreve 1 no bit de write
    bic r3, r3, #0x01F80000
    lsl r1, r1, #19
    eor r3, r3, r1
    
    str r3, [r2]

    bic r3, r3, #0x00040000 @ Escreve 0 no bit de write
    
    str r3, [r2]

    mov r0, #0

    ldmfd sp, {r1-r10}
    movs pc, lr

set_motor1:
    stmfd sp, {r1-r10}

    mov r2, #0x53F84000 @ Endereço do registrador de dados da GPIO
    ldr r3, [r2]

    orr r3, r3, #0x02000000 @ Escreve 1 no bit de write
    bic r3, r3, #0xFC000000
    lsl r1, r1, #26
    eor r3, r3, r1
    
    str r3, [r2]

    bic r3, r3, #0x02000000 @ Escreve 0 no bit de write
    
    str r3, [r2]

    mov r0, #0

    ldmfd sp, {r1-r10}
    movs pc, lr

@/set_motor_speed

get_time:
    mov r0, SYS_TIME
    ldr r0, [r0]

    movs pc, lr

.data
SYS_TIME:
	.word 0x0
