
_start:
    addi x2, x0, 45
    addi x3, x0, 29
    add  x4, x2, x3
    xor  x4, x2, x3
    sub  x5, x2, x3
    sub  x6, x3, x2
    slli  x7, x6, 2
    j _jump_test
    nop
    nop
    nop
_jump_test:
    nop
    nop
    addi x2, x0, 43
    addi x3, x0, 24
    or   x4, x2, x3
    addi x8, x0, 59
    beq  x4, x8, _jalr_test
    nop
    nop
    nop
_jalr_test:
    srli x5, x2, 2
    la   x2, _exit
    jalr x1, x2, 0
    nop
    nop
    nop
_exit:
    beqz x0, _beq_test
