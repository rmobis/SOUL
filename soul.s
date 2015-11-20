@ vim:ft=armv5

@ CONSTANTS
.set GPT_BASE,        0x53FA0000
.set GPT_CR,          0x00
.set GPT_PR,          0x04
.set GPT_SR,          0x08
.set GPT_IR,          0x0C
.set GPT_OCR1,        0x10

.set TZIC_BASE,       0x0FFFC000
.set TZIC_INTCTRL,    0x00
.set TZIC_INTSEC1,    0x84
.set TZIC_ENSET1,     0x0104
.set TZIC_PRIOMASK,   0x0C
.set TZIC_PRIORITY9,  0x0424

.set GPIO_BASE,       0x53F84000
.set GPIO_DR,         0x00
.set GPIO_GDIR,       0x84
.set GPIO_PSR,        0x84

.set SUPERVISOR_MODE, 0x13
.set USER_MODE,       0x10

.set USER_TEXT,       0x77802000
.set TIME_SZ,         200000
.set MAX_ALARMS,      8
.set MAX_CALLBACKS,   8

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


RESET_HANDLER:
    @ Sets the start address of the interrupt vector on the co-processor
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    @ Resets the system clock
    ldr r0, =SYS_TIME
    mov r1, #0
    str r1, [r0]

SETUP_GPT:
    ldr r0, =GPT_BASE

    @ Enables GPT, specifically on Stop and Wait modes
    ldr r1, =0x41
    str r1, [r0, #GPT_CR]

    @ Sets the scale to 1
    mov r1, #0
    str r1, [r0, #GPT_PR]

    @ Enables the Output Control Channel 1
    mov r1, #1
    str r1, [r0, #GPT_IR]

    @ Sets the interval for the interruption
    ldr r1, =TIME_SZ
    str r1, [r0, #GPT_OCR1]


SETUP_TZIC:
    ldr r0, =TZIC_BASE

    @ Sets GPT (39th) interruption as non-secure
    mov r1, #(1 << 7)
    str r1, [r0, #TZIC_INTSEC1]

    @ Enables GPT (39th) interruption
    mov r1, #(1 << 7)
    str r1, [r0, #TZIC_ENSET1]

    @ Sets the interrupt priority to 1 (0 is highest)
    ldr r1, [r0, #TZIC_PRIORITY9]
    bic r1, r1, #0xFF000000        @ Clears the first 8 bits
    mov r2, #1
    orr r1, r1, r2, lsl #24        @ Sets the bit 7 to 1
    str r1, [r0, #TZIC_PRIORITY9]

    @ Zeroes the priority mask
    mov r1, #0
    str r1, [r0, #TZIC_PRIOMASK]

    @ Enables interruptions
    mov r1, #1
    str r1, [r0, #TZIC_INTCTRL]

    @ Goes into supervisor mode
    msr CPSR_c, #SUPERVISOR_MODE


SETUP_GPIO:
    ldr r0, =GPIO_BASE

    @ Correctly configures input and output lines for the Uóli robot
    ldr r1, =0b11111111111111000000000000111110
    str r1, [r0, #GPIO_GDIR]

    @ Goes into user mode
    msr CPSR_c, #USER_MODE

    @ Transfers control to user code
    ldr r3, =USER_TEXT
    bx r3




.include "handlers/irq.s"

.include "handlers/syscall.s"


@read_sonar
.include "syscalls/readsonar.s"

@set_motor_speed
.include "syscalls/setmotorspeed.s"

@get_time
.include "syscalls/gettime.s"

@set_alarm
.include "syscalls/setalarm.s"

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
