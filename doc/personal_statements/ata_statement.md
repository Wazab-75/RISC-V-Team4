## Individual Personal Statement - Ata (Wazab_75)
**Name:** Athanase de Germay de Cirfontaine

**Role:** Repository Manager

**CID:** 02490080

## Overview
- [Introduction](#introduction)
- [Single Cycle CPU](#single-cycle-cpu)
    - [ALU Execution Unit](#alu-execution-unit)
    - [Cache Memory](#cache-memory)
    - [Testing](#testing)
- [Merge of Cache and Pipeline](#merge-of-cache-and-pipeline)
- [Challenges](#challenges)
- [Learning Outcomes](#learning-outcomes)
- [Conclusion](#conclusion)

## Introduction
During this project, I have been mainly working on the single-cycle CPU, building the ALU execution unit and the cache memory. I have contributed to the design of:
- The ALU execution unit (single-cycle)
- Direct Mapped Cache Memory
- Two-way Set Associative Cache Memory

Once the cache design was completed, I then worked on the merge of the cache and pipeline implementation to create a fully functional CPU.

This document will provide an overview of the work I have done, the challenges encountered, and the learning outcomes.

## Single Cycle CPU

The single-cycle CPU was initially divided into four major components:
- `Fetch` (PC and Instruction Memory)
- `Decode` (Control Unit)
- `Execute` (ALU Execution Unit / Registers)
- `Memory` (Cache Memory)

![cpu](../image/single_cycle_cpu.png)

We also wanted to keep the `top.sv` file clean and easy to read. Therefore, we created a module for each component. This allowed us to debug and test each module separately.

### ALU Execution Unit

Relevant commits:
- [ALU Optimization Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/ce6b6eb8ddd7d1232843c0a443dd6ad78447bea0)

During the first part of the project, I worked on the ALU Execution Unit and the register files, which are part of the Execute stage. The ALU Execution Unit was designed to perform the following operations:

```sv
 always_comb begin
    case (ALUctrl)
        3'b000:     ALUout = ALUop1 + ALUop2;            // ADD

        3'b001:     ALUout = ALUop1 - ALUop2;            // SUB

        3'b010:     ALUout = ALUop1 & ALUop2;            // AND

        3'b011:     ALUout = ALUop1 | ALUop2;            // OR

        3'b100:     ALUout = ALUop1 ^ ALUop2;

        3'b101:     ALUout = (ALUop1 < ALUop2) ? 1 : 0;  // SLT
    endcase
    EQ = (ALUout == 0'b0) ? 1 : 0;                       // BNE
end
```

For the purpose of lab4, these instructions were largely sufficient to perform the operations. Later on, I expanded the ALU to include shift and jump instructions. Additionally, we extended the width of the `ALUctrl` to include all the different instructions.

To make the modules more readable, we also created a `def.sv` module to define the different instructions. This helped us modify the instructions and avoid any conflicts.

Finally, I added the 32-bit register module to complete the ALU execution unit.

### Cache Memory

Building the main memory was not particularly challenging. However, implementing the cache memory required a significant amount of time and effort. The memory is divided into four parts:
- [data_mem.sv](../../repo/rtl/memory/data_mem.sv)
- [cache_mem.sv](../../repo/rtl/memory/cache_mem.sv)
- [top_memory.sv](../../repo/rtl/memory/top_memory.sv)
- [inst_mem.sv](../../repo/rtl/memory/inst_mem.sv)

#### 1) Data_mem.sv:

<p align="center">
    <img src="../image/mem_structure.png" alt="Memory Structure">
</p>

We decided to separate the data and the instructions to simplify the cache memory implementation. The `data_mem` is constrained to read and store data between the addresses `0x00000000` and `0x0001FFFF`:

```sv
logic [7:0] ram_array [32'h0001FFFF:0];
```

Our main goal was to access the main memory as little as possible to reduce latency. Therefore, we implemented a write-back policy to update the cache memory only when the data is overwritten. Whenever the data is modified, the dirty bit is set to 1, and if it gets overwritten, the data is written back to the main memory.

Additionally, the memory replaces the old data with four words of the called address. It is important to note that the data is byte-addressed and little-endian for greater flexibility.

```sv	
ReadData = {ram_array[addr + 3], ram_array[addr + 2], ram_array[addr + 1], ram_array[addr]};
```

#### 2) Cache_mem.sv:

Relevant commits:
- [2-set Cache Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/61c879e98349d58a8ac151de5a6c098b6cf21ffb#diff-52bee97fad294c9147e8cc98e4a4e59f6c17979731b57ac4a3899755c9abee33)
- [2-way Set-Associative Cache Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/c9236c5e331d16947c3be5d0d1502ec874d8ab73)

This module is the most important part of the cache memory. Initially, we opted for a simple two-set cache memory with four blocks, as it was easier to test and debug.

![2_set_cache](../image/2_set_cache.png)

Once the two-set cache worked, we changed the structure to implement a 2-way set associative cache memory with 128 sets and 4 blocks per set. This provided a capacity of 4096 bytes.

```sv
module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,    // 4 words per block
              WAYS       = 2,    // 2-way associative
              NUM_SETS   = 128 
)
```

This module is divided into two parts:
- The management of the cache memory (clocked at the positive edge)
- The read output implementation (sent when data is requested)

The first role of the cache is to decode the address and find the corresponding set and block. If the data is found in the cache, the signal `cache_read` returns the data selected by (`func3`). If there is a miss, the cache sends a request to the main memory and stores the fetched data in its memory.

```sv
assign tag         = addr[31:11];
assign index       = addr[10:4];
assign offset      = addr[3:2];  
assign byte_offset = addr[1:0];  
```

The management of the cache memory follows these principles: If the data in the cache is correct, the valid bit is set to 1. If the data is modified, the dirty bit is set to 1. In case of a miss, a `fetch_enable` signal is sent to the memory to fetch the data. If the data corresponding to the same address in the cache is valid, the cache writes the data back to the main memory.

```sv
output logic [4*DATA_WIDTH-1:0]  write_back_data,
output logic                     write_back_valid,
output logic [DATA_WIDTH-1:0]    write_back_addr;


// Read miss
if (v[index][replace_way] && d[index][replace_way]) begin
    // Write back dirty block
    for (int i = 0; i < BLOCK_SIZE; i++)
        write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[index][replace_way][i];

    write_back_addr  <= {tag_array[index][replace_way], index, 4'b0000};
    write_back_valid <= 1'b1;
end
```

Instead of waiting for the `fetch_data` to be stored and then read, we immediately send the data to the `top_memory` via the `read_cache` output. This reduces latency and the time needed to access the data.