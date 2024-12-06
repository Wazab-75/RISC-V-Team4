# RISC-V RV32I Processor

## Project Description
A RISC-V RV32I processor was implemented with cache and pipelining...

## Team #4 Members

| Athanase de Germay de Cirfontaine (repo manager) | Radaan Kumar Madhan| Ivy Yu | Will Zhang |
|-|-|-|-|


## Team Contribution

- Work Contribution Table
- `/` refers to **minor contribution**
- `X` refers to **major contribution**

| Steps        | Files                         |Radaan (RadaanMadhan)| Will (will03216) | Ivy (Ivy-yu7) | Athanase (Wazab-75)|
| ------------ | ----------------------------- | ------------------ | ---------------- | ------------------------ | ---------------- |
| Lab 4        | Program Counter               |                    |                  |                          |                  |
|              | ALU                           |                    |                  |                          |                  |
|              | Register File                 |                    |                  |                          |                  |
|              | Instruction Memory            |                    |                  |                          |                  |
|              | Control Unit                  |                    |                  |                          |                  |
|              | Sign Extend                   |                    |                  |                          |                  |
|              | Testbench                     |                    |                  |                          |                  |
| Single Cycle | Data Memory                   |                    |                  |                          |                  |
|              | Program Counter               |                    |                  |                          |                  |
|              | ALU                           |                    |                  |                          |                  |
|              | Register File                 |                    |                  |                          |                  |
|              | Instruction Memory            |                    |                  |                          |                  |
|              | Control Unit                  |                    |                  |                          |                  |
|              | Sign Extend                   |                    |                  |                          |                  |
| Pipeline     | Pipeline flip-flop stages     |                    |                  |                          |                  |
|              | Hazard unit                   |                    |                  |                          |                  |
| Cache        | Memory                        |                    |                  |                          |                  |
|              | Direct mapped cache           |                    |                  |                          |                  |
|              | Two-way set associative cache |                    |                  |                          |                  |

## Project Progression
```mermaid
    gitGraph
       checkout main
       commit id: "Basic Lab 4 CPU"
       commit id: "Single-Cycle CPU"

       branch pipeline
       branch cache

       checkout pipeline
       commit id: "Pipeline flip-flop stages"
       commit id: "Hazard unit"

       checkout cache
       commit id: "Memory"
       commit id: "Direct mapped cache"

       checkout pipeline
       commit id: "Debugging"
       commit id: "F1 program"
       commit id: "PDF program"

       checkout main
       merge pipeline
       merge cache
       commit id: "Combine Pipeline and Cache"
       commit id: "Complete CPU"
```
