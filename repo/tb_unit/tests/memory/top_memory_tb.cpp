#include "testbench.h"
#include <cstdlib>

#define CYCLES 10000

unsigned int ticks = 0;

class TopMemoryTestbench : public Testbench {
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
};

TEST_F(TopMemoryTestbench, WriteAndReadTest) {
    initializeInputs();
    top->ALUResult = 0x10;
    top->WriteData = 0xBA9DF1E3;
    top->MemWrite = 1;
    top->funct3 = 0b010;
    runSimulation(1);  // Simulate one clock cycle
    top->MemWrite = 0;

    top->ALUResult = 0x10;
    top->MemRead = 1;
    runSimulation(1);  // Simulate one clock cycle
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0xBA9DF1E3) << "Mismatch during read after write.";
}

TEST_F(TopMemoryTestbench, DirtyBlockWriteBackTest) {
    initializeInputs();
    top->funct3 = 0b010;

    top->ALUResult = 0x10;
    top->WriteData = 0xABA011C4;
    top->MemWrite = 1;
    top->funct3 = 0b010;
    runSimulation(1);
    top->MemWrite = 0;

    top->ALUResult = 0x30;
    top->MemRead = 1;
    runSimulation(1);
    top->MemRead = 0;

    top->ALUResult = 0x10;
    top->MemRead = 1;
    runSimulation(1);
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0xABA011C4) << "Expected ResultSrc to point to memory during fetch.";
}

TEST_F(TopMemoryTestbench, PartialWriteTest) {
    initializeInputs();
    top->ALUResult = 0x10;
    top->WriteData = 0xABCD12FD;
    top->MemWrite = 1;
    top->funct3 = 0b001;
    runSimulation(1);
    top->MemWrite = 0;

    top->ALUResult = 0x10;
    top->MemRead = 1;
    runSimulation(1);
    top->MemRead = 0;

    EXPECT_EQ(top->Result, 0x000012FD) << "Partial write/read mismatch.";
}

TEST_F(TopMemoryTestbench, CacheEvictionPolicyTest) {
    initializeInputs();
    top->funct3 = 0b010;
    top->ALUResult = 0x10;
    top->WriteData = 0xFFABC763;
    top->MemWrite = 1;
    runSimulation(1);

    top->ALUResult = 0x30;
    top->WriteData = 0x1234BEEF;
    runSimulation(1);
    top->MemWrite = 0;
    runSimulation(1);
    top->MemRead = 1;

    top->ALUResult = 0x10;
    runSimulation(2);  // Simulate two clock cycles

    EXPECT_EQ(top->Result, 0xFFABC763) << "Evicted data mismatch in memory.";
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
