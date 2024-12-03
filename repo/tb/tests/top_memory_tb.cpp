#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class TopMemoryTestbench : public BaseTestbench {
protected:
    void initializeInputs() override {
        top->clk = 0;
        top->ALUResult = 0;
        top->WriteData = 0;
        top->ResultSrc = 1;
        top->MemWrite = 0;
        top->MemRead = 0;
        top->funct3 = 0;
    }

    void simulateClockCycle() {
        top->clk = 1;
        top->eval();
        tfp->dump(ticks++); // Capture the waveform
        top->clk = 0;
        top->eval();
        tfp->dump(ticks++);
    }

    void reset() {
        initializeInputs();
        simulateClockCycle(); // Allow the system to reset properly
    }

    void finalizeSimulation() {
        for (int i = 0; i < 10; i++) {
            simulateClockCycle(); // Ensure extra clock cycles to capture all activity
        }
    }
};


// Test 1: Write and Read (Basic Functionality)
TEST_F(TopMemoryTestbench, WriteAndReadTest) {
    reset();
    // Write to memory through the cache
    top->ALUResult = 0x10;
    top->WriteData = 0xDEADBEEF;
    top->MemWrite = 1;
    top->funct3 = 0b010;  // Full word write
    simulateClockCycle();
    top->MemWrite = 0;

    // Read back the same data
    top->ALUResult = 0x10;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0xDEADBEEF) << "Mismatch during read after write.";
}


// Test 3: Dirty Block Write-Back
TEST_F(TopMemoryTestbench, DirtyBlockWriteBackTest) {
    reset();
    top->funct3 = 0b010; // Full word read

    // Step 1: Write to an address to mark it as dirty
    top->ALUResult = 0x10;       // Address 0x10
    top->WriteData = 0xBEEFCAFE; // Data to write
    top->MemWrite = 1;
    top->funct3 = 0b010;         // Full word write
    simulateClockCycle();
    top->MemWrite = 0;

    // Step 2: Access a new block to trigger eviction
    top->ALUResult = 0x30; // Address 0x30 in a different block
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;
    
    // Step 3: Optionally verify the cache state after eviction
    top->ALUResult = 0x10; // Re-access address 0x10
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    // Ensure cache miss occurred and correct data fetched back
    EXPECT_EQ(top->Result, 0xBEEFCAFE) << "Expected ResultSrc to point to memory during fetch.";
}


// Test 4: Partial Write and Read
TEST_F(TopMemoryTestbench, PartialWriteTest) {
    reset();
    // Perform a half-word write
    top->ALUResult = 0x10;
    top->WriteData = 0x00FFFACE;
    top->MemWrite = 1;
    top->funct3 = 0b001;  // Half-word write
    simulateClockCycle();
    top->MemWrite = 0;

    // Read back the data
    top->ALUResult = 0x10;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0x0000FACE) << "Partial write/read mismatch.";
}


// Test 5: Cache Eviction Policy
TEST_F(TopMemoryTestbench, CacheEvictionPolicyTest) {
    reset();
    top->funct3 = 0b010; // Full word read
    // Write data to cache to fill one set
    top->ALUResult = 0x10;
    top->WriteData = 0xCAFEBABE;
    top->MemWrite = 1;
    simulateClockCycle();

    // Trigger eviction with a new block in the same set
    top->ALUResult = 0x30; // Different block, same set
    top->WriteData = 0xDEADFACE;
    simulateClockCycle();
    top->MemWrite = 0;
    simulateClockCycle();  
    // Assert eviction
    top->MemRead = 1;

    top->ALUResult = 0x10; // Re-access the evicted block
    simulateClockCycle();
    simulateClockCycle();

    EXPECT_EQ(top->Result, 0xCAFEBABE) << "Evicted data mismatch in memory.";
}


int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);

    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
