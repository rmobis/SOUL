@ vim:ft=armv5

@ CONSTANTS
.include "constants.s"

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

    @ IRQ mode
    msr CPSR_c, 0x12
    ldr sp, =irq_stack

    @ Goes into supervisor mode
    msr CPSR_c, #SUPERVISOR_MODE

    @ Sets supervisor stack pointer
    ldr sp, =svc_stack


SETUP_GPIO:
    ldr r0, =GPIO_BASE

    @ Correctly configures input and output lines for the Uóli robot
    ldr r1, =0b11111111111111000000000000111110
    str r1, [r0, #GPIO_GDIR]

    @ Goes into user mode
    msr CPSR_c, #USER_MODE

    @ Sets user stack pointer
    ldr sp, =user_stack

    @ Transfers control to user code
    ldr r3, =USER_TEXT
    mov pc, r3




.include "handlers/irq.s"

.include "handlers/syscall.s"


@read_sonar
.include "syscalls/readsonar.s"

@register_proximity_callback
.include "syscalls/registerproximitycallback.s"

@set_motor_speed
.include "syscalls/setmotorspeed.s"

@set_motors_speed
.include "syscalls/setmotorsspeed.s"

@get_time
.include "syscalls/gettime.s"

@set_time
.include "syscalls/settime.s"

@set_alarm
.include "syscalls/setalarm.s"

.data
SYS_TIME:
    .word 0x0

num_alarms:
    .word 0x0

prox_alarm:
    .word -1 @ We initialize with -1 because that's the biggest unsigned value
    .word 0 @ Position of the next alarm on the alarms vector

alarms_vector:
    @ Each alarm is represented by 2 blocks of 4 bytes; the first one stores the
    @ scheduled time and the second one, the routine's address
    .fill 8*MAX_ALARMS

num_callbacks:
    .word 0
callback_vector:
    @ Each callback is represented by 3 blocks: one 2 byte long for the sonar
    @ identifier, one 2 bytes long for the proximity threshold and one 4 bytes
    @ long for the routine's address
    .fill 8 * MAX_CALLBACKS

user_stack:
    .fill 8*user_stack_size

irq_stack:
    .fill 8*irq_stack_size

svc_stack:
    .fill 8*svc_stack_size
