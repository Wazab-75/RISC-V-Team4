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
        tfp->dump(ticks++);
        top->clk = 0;
        top->eval();
        tfp->dump(ticks++);
    }

    void reset() {
        initializeInputs();
        simulateClockCycle();
    }

    void finalizeSimulation() {
        for (int i = 0; i < 10; i++) {
            simulateClockCycle();
        }
    }
};

TEST_F(TopMemoryTestbench, WriteAndReadTest) {
    reset();
    top->ALUResult = 0x10;
    top->WriteData = 0xDEADBEEF;
    top->MemWrite = 1;
    top->funct3 = 0b010;
    simulateClockCycle();
    top->MemWrite = 0;

    top->ALUResult = 0x10;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0xDEADBEEF) << "Mismatch during read after write.";
}

TEST_F(TopMemoryTestbench, DirtyBlockWriteBackTest) {
    reset();
    top->funct3 = 0b010;

    top->ALUResult = 0x10;
    top->WriteData = 0xBEEFCAFE;
    top->MemWrite = 1;
    top->funct3 = 0b010;
    simulateClockCycle();
    top->MemWrite = 0;

    top->ALUResult = 0x30;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;
    
    top->ALUResult = 0x10;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0xBEEFCAFE) << "Expected ResultSrc to point to memory during fetch.";
}

TEST_F(TopMemoryTestbench, PartialWriteTest) {
    reset();
    top->ALUResult = 0x10;
    top->WriteData = 0x00FFFACE;
    top->MemWrite = 1;
    top->funct3 = 0b001;
    simulateClockCycle();
    top->MemWrite = 0;

    top->ALUResult = 0x10;
    top->MemRead = 1;
    simulateClockCycle();
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0x0000FACE) << "Partial write/read mismatch.";
}

TEST_F(TopMemoryTestbench, CacheEvictionPolicyTest) {
    reset();
    top->funct3 = 0b010;
    top->ALUResult = 0x10;
    top->WriteData = 0xCAFEBABE;
    top->MemWrite = 1;
    simulateClockCycle();

    top->ALUResult = 0x30;
    top->WriteData = 0xDEADFACE;
    simulateClockCycle();
    top->MemWrite = 0;
    simulateClockCycle();
    top->MemRead = 1;

    top->ALUResult = 0x10;
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
