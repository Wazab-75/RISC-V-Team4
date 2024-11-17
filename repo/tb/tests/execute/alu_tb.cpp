/*
 *  Verifies the results of the mux, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ALUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUctrl = 0;
        // output: out
    }
};

TEST_F(ALUTestbench, ALU0WorksTest)
{
        top->ALUop1 = 5;
        top->ALUop2 = 12;
        top->ALUctrl = 0b000;

    top->eval();

    EXPECT_EQ(top->ALUout, 17);
}

TEST_F(ALUTestbench, ALU1WorksTest)
{
        top->ALUop1 = 12;
        top->ALUop2 = 12;
        top->ALUctrl = 0b001;

    top->eval();

    EXPECT_EQ(top->ALUout, 0);
    EXPECT_EQ(top->EQ, 1);
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
