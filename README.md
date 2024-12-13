# RV32M - multiplication 

## Overview
In this branch, we extended the functionality of our design by partially implementing the RV32M extension of the RISC-V instruction set. Specifically, we incorporated the MUL instruction, which performs integer multiplication. This addition enhances the computational capabilities of our system.

## Design Decisions
While the RV32M extension includes a range of arithmetic operations, such as division (DIV), and remainder (REM), we deliberately chose to implement only the MUL instruction. This decision was because our system focuses on integer arithmetic, and we do not currently support floating-point operations, which makes certain instructions in the RV32M extension less relevant to our goals.

## Implementation Details
The addition of the MUL instruction required modifications to two primary modules in our system:

Control Unit: Adjustments were made to recognize the MUL instruction in the instruction decoding process and generate appropriate control signals to direct the execution flow.

Arithmetic Logic Unit (ALU): The ALU was enhanced to perform multiplication operations. 

To ensure the correctness and reliability of our implementation, comprehensive testbenches were developed and executed. 

Future work could explore implementing the remaining instructions of the RV32M extension, perhaps using floating point instead of integers. 