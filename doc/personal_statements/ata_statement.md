## Individual Personal Statement - Ata (Wazab_75)
**Name:** Athanase de Germay de Cirfontaine

**Role:** Repository Manager

**CID:** 02490080

## Overview
- [Introduction](#introduction)
- [Single Cycle CPU](#single-cycle-cpu)
    - [ALU Execution Unit](#alu-execution-unit)
    - [Cache Memory](#cache-memory)
    - [Testings](#testings)
- [Merge of Cache and Pipeling](#merge-of-cache-and-pipeline)
- [Challenges](#challenges)
- [Learning Outcomes](#learning-outcomes)
- [Conclusion](#conclusion)


## Introduction
During this project, I have been manly working on the single cycle CPU, building the alu execution unit and the cache memory. I have contributed to the design of:
- The ALU execution unit (single cycle)
- Direct Mapped Cache Memory
- Two-way Set Associative Cache Memory

Once the cache design was completed, I then worked on the merge of the cache and pipeline implementation to create a fully functional CPU.

This document will provide an overview of the work I have done, the challenges and the learning outcomes.

## Single Cycle CPU

The single cycle CPU was at first divided into 4 major components:
- Fetch (PC and Instruction Memory)
- Decode (Control Unit)
- Execute (ALU Execution Unit / Registers)
- Memory (Cache Memory)

![cpu](../image/single_cycle_cpu.png)

We also wanted to keep the top.sv file clean and easy to read. Therefore, we created a module for each of the components. This allowed us to easily debug and test each module separately.

### ALU Execution Unit

Relevant commits:
- [Alu optimization Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/ce6b6eb8ddd7d1232843c0a443dd6ad78447bea0)

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

For the purpuse of the lab4, those instructions were largly sufficient to perform the operations. Later on, I expended the ALU to include the shift and jump instructions. In addition of that, we also extended the width of the ALUctr to include all different instructions. 

To make the modules more readable we also created a def.sv mdoule to define the different instructions. This also helped use to modify the instructions and avoid any conflicts.

Finally, I added the 32 bits register module to complete the alu execution unit.

### Cache Memory

Building the main memory was not such a challenging task. However, implementing the cache memory required a lot of time and effort. The memory is divided into four parts:
- [data_mem.sv](../../repo/rtl/memory/data_mem.sv)
- [cache_mem.sv](../../repo/rtl/memory/cache_mem.sv)
- [top_memory.sv](../../repo/rtl/memory/top_memory.sv)
- [inst_mem.sv](../../repo/rtl/memory/inst_mem.sv)

#### 1) Data_mem.sv : 

<p align="center">
    <img src="../image/mem_structure.png" alt="Memory Structure">
</p>

We decided to separate the data and the instructions to make the cache memory implementation easier. The data_mem is then contrained to read and store data between the addresses 0x00000000 and 0x0001FFFF :

```sv
logic [7:0] ram_array [32'h0001FFFF:0];
```

Our main goal was to access the main memory as little as possible to reduce the latency. Therefore, we implemented a write back policy to update the cache memory only when the data is overwritten. When ever the data is modified, the dirty bit is set to 1 then if it gets overwritten, the data is written back to the main memory. 

In addition of that, the memory replace the old data with four words of the address called. It is also important to note that the data is byte addressed and little endian to have more flexibility.

```sv	
ReadData = {ram_array[addr + 3], ram_array[addr + 2], ram_array[addr+ 1], ram_array[addr]};
```

#### 2) Cache_mem.sv : 

#### Relevant commits:
- [2-set Cache Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/61c879e98349d58a8ac151de5a6c098b6cf21ffb#diff-52bee97fad294c9147e8cc98e4a4e59f6c17979731b57ac4a3899755c9abee33)
- [2-way Set-Associative Cache Commit](https://github.com/Wazab-75/RISC-V-Team4/commit/c9236c5e331d16947c3be5d0d1502ec874d8ab73)

This module is the most important part of the cache memory. At first we opted for a simple two set cache memory with four blocks as it was easier to test and debug.

![2_set_cache](../image/2_set_cache.png)

Once the two set cache worked we changed the structure to implement a 2-way set associative cache memory with 128 sets and 4 blocks per set. That way, we could have a capacity of 4096 bytes.

```sv
module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,    // 4 words per block
              WAYS       = 2,    // 2-way associative
              NUM_SETS   = 128 
)
```

This module is then divided into two parts:

- The gestion of the cache memory (clocked at the positive edge)
- The read output implementation (sent when data is requested)

The first role of the cache is to decode the address and find the corresponding set and block. If the data is found in the cache, the signal cache_read returns the data selected by (func3). If there is a miss, the cache sends a request to the main memory and stores the fetch_data in it's memory.

```sv
assign tag         = addr[31:11];
assign index       = addr[10:4];
assign offset      = addr[3:2];  
assign byte_offset = addr[1:0];  
```

The gestion of the cache memory is done by the following principles. If the data in the cache is correct, the valid bit is set to 1. If the data is modified, the dirty bit is set to 1. In case of a miss, a fetch_enable signal is sent to the memory to fetch the data. But if the data corresponding to the same address in the cache is valid, the cache starts to write back the data to the main memory.

```sv
output logic [4*DATA_WIDTH-1:0]  write_back_data,
output logic                     write_back_valid,
output logic [DATA_WIDTH-1:0]    write_back_addr


// Read miss
if (v[index][replace_way] && d[index][replace_way]) begin
    // Write back dirty block
    for (int i = 0; i < BLOCK_SIZE; i++)
        write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[index][replace_way][i];

    write_back_addr  <= {tag_array[index][replace_way], index, 4'b0000};
    write_back_valid <= 1'b1;
end
```

Finally, instead of waiting for the fetch_data to be stored and then read, we imediatly send the data to the top_memory via read_cache output. This way, we reduce the latency and the time needed to access the data.

## Testings

The testing in general is the most imortant part of the project as you need to make sure that every single possibility is taken into account. We thought that each single module should be tested indepanently to avoid any potential errors and waste of time. This is why before using the provided testbench, we created our own testbenches to test the modules in [tb_unit](../../repo/tb_unit/).

The testbenche created for the cache consisted of 5 tests, 3 of which conserned most of the features already covered by the main memory, to verify that nothing was corrupted. Then the last 2 tests were centered around the misses and hit of the cache memory. 

#### Relevant testbenche:
- [top_memory_tb.cpp](https://github.com/Wazab-75/RISC-V-Team4/blob/cache/repo/tb_unit/tests/top_memory_tb.cpp)



## Merge of Cache and Pipeline



## Challenges

During this project, my main problem was to manage the signals from cache memory to main memory and interpret them in the same way. At first, data_mem was in little endian and byte addressed, while the cache memory was in big endian and word addressed. This caused a lot of confusion and errors in the data transfer. An other issue that I encountered was the management of the offset and the byte offset. The address received via the alu and then procesed by the main memory was not always aligned with the data stored in the cache. The memory was then sending four words thats should normally be stored in different sets to the cache. This caused a lot of confusion, as I was inspecting the signals and the wrong part of the data was processed.

## Learning Outcomes

In my opinion, the most important part of this project was the gestion of the project itself. All of the team member had to work together to make sure that the poject was evolving in the right direction. Instead of having one single way of doing things, each individual had to make sure that its work could be easily integrated with the rest of the project. This is why creating modules like def.sv was so important, to preserve a structure and avoid any conflicts.

The second most important part, outside of simply technical knowledge, was to manage a git repository. We are all refronted to this tool in our daily work, but we never truly take the time to learn the features and maintain a clean repository while working alone. This project was a great opportunity for me to avoid putting it off until later.

Finally, I learned a lot about the architecture of a CPU. Even though we learned all those compoents in the course itself, it never equals the experience gained when you have to implement it yourself. Your understanding of the subject is not comparable to what you learn in the course as you have to deaply understand the link between each wire and each module.

## Conclusion

Learning the RISCV architecture was a great oportunity, not only because it teaches us how a CPU works, but also because this knowledge is very important in the industry and could be very useful in the future.



