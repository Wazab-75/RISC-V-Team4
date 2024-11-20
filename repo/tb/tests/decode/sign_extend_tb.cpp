/*
 *  Verifies the results of the sign extender, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class SignExtendTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->Imm_up = 0;
        top->Imm_down = 0;
        top->ImmSrc = 2;
        // output: out
    }
};

TEST_F(SignExtendTestbench, ImmIWorksTest)
{
    top->Imm_up = 1;
    top->Imm_down = 0;
    top->ImmSrc = 0;

    top->eval();

    EXPECT_EQ(top->ImmExt, 1);
}

TEST_F(SignExtendTestbench, ImmBWorksTest)
{
        top->Imm_up = 0b110010100000;
        top->Imm_down = 0b00100;
        top->ImmSrc = 2;

    top->eval();

    EXPECT_EQ(top->ImmExt, 0xFFFFF4A4);
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
