init:
    addi s1, zero, 0x1      # trigger destination set as 1 
    addi s2, zero, 0xff     # light destination as 0xff 
    addi s3, zero, 0x24     # regular delay set as 0x24(1s)
    addi a3, zero, 0x7f     # the initial value of LFSR 

rst:
    addi a0, zero, 0x0      # a0 is output 
    addi a4, zero, 0x0      # a4 is increment of light 
    addi t0, zero, 0x0      # t0 is trigger 

mainloop:
    beq t0, s1, light_up    
    srli t1, a3, 2
    andi t1, t1, 0x1
    srli t2, a3, 6
    andi t2, t2, 0x1
    xor t1, t1, t2          # new last bit 
    andi t2, a3, 0x3f
    slli t2, t2, 1
    add t1, t1, t2          # Add two segments 
    andi a3, t1, 0x7f       # Return results 
    jal ra, mainloop        # Loop 

light_up:
    jal ra, lightdelay      # add const delay 
    slli t1, a0, 0x1        # shift left temp bits 
    addi a0, t1, 0x1        # add 1 to shifted temp bits 
    bne a0, s2, light_up    # loop only if not all lights are on 

final_random:
    beq a4, a3, rst         # if reached final state, reset 
    addi a4, a4, 0x1        # inc delay 
    jal ra, final_random    # run until delay finished 

lightdelay:
    addi a1, a1, 0x1        # inc count 
    bne a1, s3, lightdelay
    addi a1, zero, 0x0      # reset count 
    RET
