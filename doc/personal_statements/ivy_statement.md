## Individual Personal Statement - Ivy 

**Name:** Ivy Yu

**CID:** 02379950

## Overview
- [Introduction](#introduction)
- [Single Cycle CPU](#single-cycle-cpu)
    - [Instruction Memory](#instruction-memory)
    - [Sign Extension](#sign-extension)
    - [Control Unit](#control-unit)
- [Cache for instruction memory](#cache-for-instruction-memory)
- [Conclusion](#conclusion)


## Introduction
In this project, my primary focus was on developing the 'decode' segment of the single-cycle CPU. This encompassed components such as the instruction memory, the sign extension module, and the control unit. Additionally, I contributed to the implementation of cache, specifically by constructing the cache for the instruction memory.

This document offers a comprehensive technical overview of my contributions, accompanied by reflections and insights gained throughout the process. This project enhanced my understanding of instruction architecture, CPU design, and SystemVerilog. Collaborating within a team of four was an incredibly rewarding experience: it was a supportive environment where ideas were exchanged and problems resolved collectively. I gained a deeper appreciation for the significance of communication and responsibility in successfully creating this CPU. 


## Single Cycle CPU

The implementation of the single-cycle CPU was divided into four sections: fetch, decode, execute, and memory. My contributions included working on part of the fetch section (instruction memory) and all of the decode section (Sign Extend and Control Unit). 

![cpu](../image/single_cycle_cpu.png)

As illustrated in the schematic above, the address flows through the instruction memory, which outputs the instruction, serving as input to the control unit, register file, and sign extend modules. The sign extend module generates a sign-extended version of the immediate value based on the instruction type. Meanwhile, the control unit produces a set of logic signals that determine the operation of the execute stage of the CPU.

The following subsections provide a detailed explanation of each module, including the key design decisions made and challenges encountered throughout the process. 

### Instruction Memory

The inst_mem module implements a ROM-based instruction memory that outputs a 32-bit instruction for a given 32-bit address from the program counter. Instructions are loaded from a "program.hex" file, and four 8-bit blocks are concatenated to form the 32-bit output. It was initially challenging to ensure that the address input accurately indexed the ROM array while maintaining proper alignment for 32-bit instructions. 

The code snippet below demonstrates the creation of the ROM array, which is reduced to 2^8 = 256 locations, each 8 bits wide. The choice to implement a 256-location ROM array with an 8-bit width was made to ensure flexibility and efficient memory usage. Memory addressing was offset by 32'hBFC00000 to replicate a realistic memory-mapped ROM address range.
```sv
    logic [7:0] rom_array [32'hBFC00FFF : 32'hBFC00000];  
```

The following code shows the concatenation of 4 consecutive 8-bit blocks to form a 32-bit instruction. A combinational block (always_comb) was utilized instead of sequential logic to enable faster instruction fetching, aligning with the simplicity and speed priorities of single-cycle CPU design.
```sv
    always_comb begin
        dout = {rom_array[(addr + 3)- 32'hBFC00000],rom_array[(addr + 2) - 32'hBFC00000],rom_array[(addr+ 1) - 32'hBFC00000],rom_array[(addr) - 32'hBFC00000]};
    end
```

##### Relevant Commits:
- TODO


### Sign Extension:
