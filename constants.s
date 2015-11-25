
.set SYSCALL_RS,        16
.set SYSCALL_RPC,       17
.set SYSCALL_SMS,       18
.set SYSCALL_SMSS,      19
.set SYSCALL_GT,        20
.set SYSCALL_ST,        21
.set SYSCALL_SA,        22

.set CALLBACK_SONAR,    0x00
.set CALLBACK_PROX,     0x02
.set CALLBACK_FUNCTION, 0x04
.set CALLBACK_SIZE,     0x07

.set GPT_BASE,          0x53FA0000
.set GPT_CR,            0x00
.set GPT_PR,            0x04
.set GPT_SR,            0x08
.set GPT_IR,            0x0C
.set GPT_OCR1,          0x10

.set TZIC_BASE,         0x0FFFC000
.set TZIC_INTCTRL,      0x00
.set TZIC_INTSEC1,      0x84
.set TZIC_ENSET1,       0x0104
.set TZIC_PRIOMASK,     0x0C
.set TZIC_PRIORITY9,    0x0424

.set GPIO_BASE,         0x53F84000
.set GPIO_DR,           0x00
.set GPIO_GDIR,         0x04
.set GPIO_PSR,          0x08

.set SUPERVISOR_MODE,   0x13
.set USER_MODE,         0x10

.set USER_TEXT,         0x77804000
.set TIME_SZ,           1000
.set MAX_ALARMS,        8
.set MAX_CALLBACKS,     8

.set user_stack_size,   100
.set svc_stack_size,    100
.set irq_stack_size,    100