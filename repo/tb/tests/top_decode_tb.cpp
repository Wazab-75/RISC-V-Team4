/*
 *  Verifies the results of the top decode unit, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class TopDecodeTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr = 0;
        top->EQ = 0;
        // output: out
    }
};

TEST_F(TopDecodeTestbench, TopDecodeAddIWorksTest)
{
    top->instr = 0x0ff00313;
    top->EQ    = 0;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ALUSrc, 0b1);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->PCSrc, 0b0);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ImmExt, 255);

}

TEST_F(TopDecodeTestbench, TopDecodeBneWorksTest)
{
    top->instr = 0xfe0318e3;
    top->EQ    = 1;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b0);
    EXPECT_EQ(top->ALUSrc, 0b0);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->PCSrc, 0b1);
    EXPECT_EQ(top->ALUctrl, 0b001);
    EXPECT_EQ(top->ImmExt, -16);
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
