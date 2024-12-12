.text
.globl main
main:
    # Load immediate values into registers
    li s0, 5          # s0 = 5
    li s1, 3          # s1 = 3

    # Perform multiplication using mul and mulh instructions
    mul t0, s0, s1     # t0 = (s0 * s1)[31:0] = 15
    mulh t1, s0, s1    # t1 = (s0 * s1)[63:32] = 0 (since 5*3=15 fits in 32 bits)

    # Add the results to get a0 = t0 + t1
    add a0, t0, t1     # a0 = 15 + 0 = 15

    # Branch to finish if a0 is nonzero, which it is (15)
    bne     a0, zero, finish

finish:
    # Loop forever, allowing inspection of a0 = 15
    bne zero, zero, finish
