register_proximity_callback:
    stmfd sp!, {r4-r6}

	@ Checks if we can still add new callbacks
	ldr r3, =num_callbacks
	ldr r4, [r3]
	cmp r4, #MAX_CALLBACKS
	movhs r0, #-1
	bhs register_proximity_callback_exit

	@ Checks for invalid sonar identifier
	cmp r0, #15
	movhi r0, #-2
	bhi register_proximity_callback_exit

	@ Finds the starting address of the next entry on the vector
	ldr r5, =callback_vector
	mov r6, #CALLBACK_SIZE
	mla r5, r4, r6, r5

	@ Stores the callback information on the vector
	strb r0, [r5, #CALLBACK_SONAR]
	strh r1, [r5, #CALLBACK_PROX]
	str r2, [r5, #CALLBACK_FUNCTION]

	@ Increments the amount of callbacks
	add r4, r4, #1
	str r4, [r3]

	@ Everything went fine, return 0
	mov r0, #0

register_proximity_callback_exit:
    ldmfd sp!, {r4-r6}
    movs pc, lr
