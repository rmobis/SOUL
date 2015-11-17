set_alarm:
    stmfd sp, {r1-r10}

    @ Testa o número de alarmes ativos
    ldr r2, =num_alarms
    ldr r3, [r2]
    cmp r3, MAX_ALARMS
    blo alarm_overflow

    @ Testa se o tempo é menor que o tempo de sistema
    ldr r4, =SYS_TIME
    ldr r4, [r4]
    cmp r4, r1
    bls too_soon

    @ Escreve o alarme no final do vetor de alarmes
    lsl r3, r3, #3
    add r4, r3, alarms_vector
    str r1, [r4]
    str r0, [r4, 4]

    @ atualiza o prox alarme, se necessário
    ldr r5, =prox_alarm
    ldr r6, [r5]
    cmp r1, r6
    strlo r1, [r5] 
    strlo r3, [r5, 4]

    @ incrementa contador de alarmes
    add r3, r3, #1
    str r3, [r2]

fim_setalarm:
    ldmfd sp, {r1-r10}
    movs pc, lr

alarm_overflow:
    mov r0, #-1
    b fim_setalarm

too_soon:
    mov r0, #-2
    b fim_setalarm
