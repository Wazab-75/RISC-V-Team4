/*
 *  Verifies the results of the top fetch block, exits with a 0 on success.
 */


#include "testbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;


class TopExecuteTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->instr_19_15 = 0;
        top->instr_24_20 = 0;
        top->instr_11_7 = 0;
        top->ALUctrl = 0;
        top->ALUSrc = 0;
        top->RegWrite = 0;
        top->Result = 0;
        top->ImmExt = 0;
    }
};


TEST_F(TopExecuteTestbench, AddIALUWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   
        if (i==2){
        top->instr_19_15 = 0;
        top->instr_24_20 = 0;
        top->instr_11_7 = 6;
        top->ALUctrl = 0;
        top->ALUSrc = 1;
        top->RegWrite = 1;
        top->ImmExt = 255;
        }
        runSimulation(1);
        //EXPECT_EQ(top->ALUResult, 255);
        if (top->ALUResult == 255)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Addi ALU doesn't work";
    }
}

TEST_F(TopExecuteTestbench, AddIRegWorksTest)
{
    bool success = false;

    for (int i = 0; i < 1000; i++)
    {   
        if (i==2){
            top->instr_19_15 = 0;
            top->instr_24_20 = 0;
            top->instr_11_7 = 6;
            top->ALUctrl = 0;
            top->ALUSrc = 0;
            top->RegWrite = 1;
            top->Result = 11; 
            top->ImmExt = 255;
        }
        if (i==3){
            top->instr_19_15 = 6;
            top->instr_24_20 = 0;
            top->instr_11_7 = 7;
            top->ALUctrl = 0;
            top->ALUSrc = 1;
            top->RegWrite = 1;
            top->Result = 0; 
            top->ImmExt = 13;           
        }
        runSimulation(1);
        //EXPECT_EQ(top->ALUResult, 255);
        if (top->ALUResult == 24)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Addi reg doesn't work";
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

