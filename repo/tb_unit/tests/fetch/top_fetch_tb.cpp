/*
 *  Verifies the results of the top fetch block, exits with a 0 on success.
 */


#include "testbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;


class TopFetchTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->PCSrc = 0;
        top->ImmExt = 0b00000;
    }
};


TEST_F(TopFetchTestbench, FetchNormalWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   

        runSimulation(1);
        if (top->pc == 12 && i==2)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "PC doesn't increment by 4";
    }
}

TEST_F(TopFetchTestbench, FetchJumpPosWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   
        if (i==3){
            top->PCSrc = 1;
            top->ImmExt = 8;
        }else{
            top->PCSrc = 0;
        }


        runSimulation(1);
        if (top->pc == 28 && i==5)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "PC doesn't jump with +ve offset";
    }
}

TEST_F(TopFetchTestbench, FetchJumpNegWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   
        if (i==3){
            top->PCSrc = 1;
            top->ImmExt = 0xFFFFFFF8;
        }else{
            top->PCSrc = 0;
        }


        runSimulation(1);
        if (top->pc == 16 && i==6)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "PC doesn't jump with -ve offset";
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

