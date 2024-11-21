/*
 *  Verifies the results of the Instruction memory, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class InstMemTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->addr = 0;
        // output: out
    }
};

TEST_F(InstMemTestbench, InstMem0WorksTest)
{
    top->addr = 0x0;

    top->eval();

    EXPECT_EQ(top->dout, 0x0FF00313);

}

TEST_F(InstMemTestbench, InstMem1WorksTest)
{
    top->addr = 0x4;

    top->eval();

    EXPECT_EQ(top->dout, 0x00000513);

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
