
/*
 *  Verifies the results of the ALU decoder, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ALUDecoderTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->funct3 = 0b000;
        top->funct7_5 = 0b0;
        top->ALUOp = 0b00;
        top->Op_5 = 0b0; 
        // output: ALUctrl
    }
};

TEST_F(ALUDecoderTestbench, ALUDecoder0WorksTest)
{
    top->funct3 = 0b000;
    top->funct7_5 = 0b0;
    top->ALUOp = 0b01;
    top->Op_5 = 0b0; 
        // output: ALUctrl

    top->eval();

    EXPECT_EQ(top->ALUctrl, 0b001);
}

TEST_F(ALUDecoderTestbench, ALUDecoder1WorksTest)
{
    top->funct3 = 0b000;
    top->funct7_5 = 0b0;
    top->ALUOp = 0b00;
    top->Op_5 = 0b0; 

    top->eval();

    EXPECT_EQ(top->ALUctrl, 0b000);
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
