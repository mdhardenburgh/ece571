add t0, zero, t2
sub t0, zero, t2
xor t1, zero, t2
or t1, zero, t2
and t0, t1, a0
and t0, zero, fp
sll tp, gp, a6
srl t0, t1, a0
sra t0, t1, a0
slt t0, t1, a0
sltu t0, zero, fp
addi t3, t1, -64
addi t3, t1, -2048
xori a7, t1, 0x4df
ori t0, fp, 0x7ff
andi t3, tp, 0x7ef
slli ra, gp, 25
slli ra, gp, 17
srli s11, t6, 31
srli s11, t6, 22
srai t3, s5, 22
slti s11, s4, 2047
slti s11, s4, -697
sltiu t0, zero, 99
sltiu t0, zero, 0
lb fp, -2047(tp)
lh t3, 2047(gp)
lw s10, 999(a6)
lbu t0, 3(tp)
lhu sp, 666(tp)
sb fp, -2047(tp)
sh t3, 2047(gp)
sw s10, 47(a6)
sw s10, 0(a6)
beq t1, t2, .-16
bne s7, a0, .-32
bne t1, zero, .-4
bne t1, gp, .-6
blt s5, a7, .-4096
blt s5, a7, .-4096
bge t0, a4, .-4
bltu tp, a3, .-4096
bgeu t4, a4, .-256
jal ra, .-78
jalr ra, t0, 2047
jalr ra, t0, -2047
jalr zero, ra, 25
jalr ra, t0, 0
lui sp, 925
lui a4, 1048575
lui a4, 0
auipc t4, 1048575
auipc tp, 665
auipc t6, 0