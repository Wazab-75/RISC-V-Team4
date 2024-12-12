### Design Overview

Pipelining is a fundamental and highly effective technique in processor design, enabling significant performance improvements by overlapping the execution of multiple instructions. Our pipelined processor is designed by dividing the execution process of a single-cycle processor into **five stages**:

1. **F (Fetch Instruction):** Fetch the instruction from memory.

2. **D (Decode):** Decode the instruction and read register values.

3. **E (Execute ALU):** Perform arithmetic or logical operations in the ALU.

4. **M (Memory Read/Write):** Access data memory for read or write operations.

5. **W (Write Register):** Write results back to the register file.

- It is important to note that not all instructions utilize every stage. For instance, instructions like `ADD` primarily involve the **D**, **E**, and **W** stages, while load instructions (`LW`) require **D**, **E**, **M**, and **W** stages. Through pipelining, multiple instructions are executed simultaneously, each occupying a different stage in the pipeline during the same clock cycle. For example: When the first instruction completes the **F** stage, the second instruction begins its **F** stage while the first instruction moves to the **D** stage.


- While pipelining significantly boosts instruction throughput, it also introduces challenges such as **data hazards** and **control hazards**:

1. **Data Hazards:** Occur when one instruction depends on the result of a previous instruction that is still in the pipeline.
2. **Control Hazards:** Arise due to branch instructions, where the next instruction's address depends on the outcome of a branch decision.

----

### Hazard Mitigation Techniques

To handle these hazards and maintain the efficiency of the pipeline, we employ the following strategies:

**Advanced Hazard Handling with a Hazard Unit:** A more sophisticated method involves designing a Hazard Unit to dynamically manage hazards through:
 - **Forwarding:** Bypass intermediate pipeline stages to supply dependent instructions with the necessary data without waiting for it to be written back to the register file.
 - **Stalling:** Pause the pipeline by freezing specific stages to resolve data dependencies or avoid incorrect execution.
 - **Flushing:** Clear invalid instructions from the pipeline, typically used to handle control hazards like branch mispredictions.

By implementing these techniques, the pipelined processor achieves both high performance and correctness, effectively managing the complexities introduced by instruction-level parallelism.

