/*
 *  Verifies the results of the pc register, exits with a 0 on success.
 */


#include "testbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;


class pc_regTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->pc_next = 0;
    }
};


TEST_F(pc_regTestbench, PCWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   
        if (i == 10){
            top->pc_next = 26;
        }
        runSimulation(1);
        if (top->pc == 26)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "PC was never 26";
    }
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

