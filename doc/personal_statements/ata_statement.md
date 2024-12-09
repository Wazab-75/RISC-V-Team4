## Individual Personal Statement - Ata (Wazab_75)
**Name:** Athanase de Germay de Cirfontaine

**Role:** Repository Manager

**CID:** 02490080

### Overview
- [Introduction](#introduction)
- [Single Cycle CPU](#single-cycle-cpu)
    - [ALU Execution Unit](#alu-execution-unit)
    - [Cache Memory](#cache-memory)
- [Merge of Cache and Pipeling](#merge-of-cache-and-pipeline)
- [Challenges](#challenges)
- [Learning Outcomes](#learning-outcomes)
- [Conclusion](#conclusion)


### Introduction
During this project, I have been manly working on the single cycle CPU, building the alu execution unit and the cache memory. I have cotributed to the design of:
- The ALU execution unit (single cycle)
- Direct Mapped Cache Memory
- Two-way Set Associative Cache Memory

Once the cache design was completed, I then worked on the merge of the cache and pipeline implementation to create a fully functional CPU.

This document will provide an overview of the work I have done, the challenges and the learning outcomes.

### Single Cycle CPU

The single cycle CPU was at first divided into 4 major components:
- Fetch (PC and Instruction Memory)
- Decode (Control Unit)
- Execute (ALU Execution Unit / Registers)
- Memory (Cache Memory)

![cpu](../image/single_cycle_cpu.png)

We also wanted to keep the top.sv file clean and easy to read. Therefore, we created a module for each of the components. This allowed us to easily debug and test each module separately.

#### ALU Execution Unit

During the first part of the project, I worked on the ALU Execution Unit and the register files which are part of the Execute stage. The ALU Execution Unit was designed to perform the following operations:

```sv
 always_comb begin
    case (ALUctrl)
        3'b000:     ALUout = ALUop1 + ALUop2;            // ADD

        3'b001:     ALUout = ALUop1 - ALUop2;            // SUB

        3'b010:     ALUout = ALUop1 & ALUop2;            // AND

        3'b011:      ALUout = ALUop1 | ALUop2;           // OR

        3'b100:     ALUout = ALUop1 ^ ALUop2;

        3'b101:     ALUout = (ALUop1 < ALUop2) ? 1 : 0;  // SLT
        endcase
    EQ = (ALUout == 0'b0) ? 1 : 0;                       // BNE
end
```

For the purpuse of the lab4, those instructions were larglt sufficient to perform the operations. Later on, I expended the ALU to include the shift and jump instructions. In addition of that, we also extended the width of the ALUct to include all different instructions. 

To make the modules more readable we also created a def.sv mdoule to define the different instructions. This also helped use to modify the instructions and avoid any conflicts.

Finally, I added the 32 bits register module to complete the alu execution unit.

#### Cache Memory

Building the main memory was not such a challenging task. However, implementing the cache memory required a lot of time and effort. The memory is divided into four parts:
- [data_mem.sv](../../repo/rtl/memory/data_mem.sv)
- [cache_mem.sv](../../repo/rtl/memory/cache_mem.sv)
- [top_memory.sv](../../repo/rtl/memory/top_memory.sv)
- [inst_mem.sv](../../repo/rtl/memory/inst_mem.sv)

1) Data_mem : The original memory module was used to store the data and the instructions following this patern:  

![mem_structure](../image/mem_structure.png)

We decided to separate the data and the instructions to make the cache memory implementation easier. The data_mem is then contrained to read and store data between the addresses 0x00000000 and 0x0001FFFF :

```sv
logic [7:0] ram_array [32'h0001FFFF:0];
```

Our main goal was to access the main memory as little as possible to reduce the latency. Therefore, we implemented a write back policy to update the cache memory only when the data is modified. When ever the data is modified, the dirty bit is set to 1 and the data is written back to the main memory. 

In addition of that, the memory replace the old data with four words of the address called. It is also important to note that the data is byte addressed and little endian to have more flexibility.

```sv	
ReadData = {ram_array[addr + 3], ram_array[addr + 2], ram_array[addr+ 1], ram_array[addr]};
```

2) Cache_mem : This module is the most important part of the cache memory. It is divided into two parts:

- The write and read overwrite implementation (clocked at the positive edge)
- The read output implementation (sent when data is requested)

[...]

### Merge of Cache and Pipeline



### Challenges


### Learning Outcomes



### Conclusion



