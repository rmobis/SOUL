set_motors_speed:
	@ Checks for invalid speed for motor 0
	cmp r0, #63
	movhi r0, #-1
	bhi set_motors_speed_exit

	@ Checks for invalid speed for motor 1
	cmp r1, #63
	movhi r0, #-2
	bhi set_motors_speed_exit

	@ Saves motor 0 speed
	mov r2, r0

	@ Prepares set_motor_speed syscall
	mov r7, #SYSCALL_SMS

	@ Sets motor 1 speed
	mov r0, #1
	svc 0x0

	@ Sets motor 0 speed
	mov r0, #0
	mov r1, r2
	svc 0x0

	@ Restores r7 value
	mov r7, #SYSCALL_SMSS

set_motors_speed_exit:
	@ Simply goes back, because the return value is already on r0
    movs pc, lr
