.text
.globl main
main:
    addi    t1, zero, 0x05      # t1 = 5
    addi    a0, zero, 0x0       # output = 0
mloop:
    lw      a0, 0(a1)           # i = 0
iloop:
    addi    a0, a1, 0           # output = i
    addi    a1, a1, 1           # i++
    bne     a1, t1, iloop       # if i != 255, goto iloop
    bne     t1, zero, mloop     # if t1 != 0 (hint: ALWAYS) goto mloop
