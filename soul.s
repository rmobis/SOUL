@ vim:ft=armv5
.set TIME_SZ, 200000
.set MAX_ALARMS, 8
.set DR, 0x53F84000
.set GDIR, 0x53F84004
.set PSR, 0x53F84008
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
    ldr r0, =GDIR

    @ Ta serto?
    ldr r1, =0b11111111111111000000000000111110
    str r1, [r0]

    @ Como vou transferir pra main do código em C??
    msr  CPSR_c, #0x10       @ SUPERVISOR mode, IRQ/FIQ enabled
    b main




.include "irqhandler.s"   

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

   
@read_sonar
.include "readsonar.s"

@set_motor_speed
.include "setmotorspeed.s"

@get_time
.include "gettime.s"

@set_alarm
.include "setalarm.s"

.data
SYS_TIME:
	.word 0x0
num_alarms:
    .word 0x0
prox_alarm:
    .word -1 @ inicializo o próximo alarme com -1 porque -1 é equivalente ao maior unsigned
    .word 0 @ posição no vetor de alarmes do próximo alarme
alarms_vector:
    .fill 8*MAX_ALARMS 
@ cada alarme é representado por 8 bytes. os quatro primeiro armazenam o tempo
@ do alarme e os quatro últimos armazenam a posição para qual se deve saltar.
