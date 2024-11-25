/*
 *  Verifies the results of the control unit, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ControlUnitTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->op = 0b0000000;
        top->funct3 = 0b000;
        top->funct7_5 = 0b0;
        top->EQ = 0b0;
        // output: out
    }
};

TEST_F(ControlUnitTestbench, AddIWorksTest)
{
    top->op = 0b0010011;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0;
    top->EQ = 0b0;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ALUSrc, 0b1);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->PCSrc, 0b0);
    EXPECT_EQ(top->ALUctrl, 0b000);

}

TEST_F(ControlUnitTestbench, BneWorksTest)
{
    top->op = 0b1100011;
    top->funct3 = 0b001;
    top->funct7_5 = 0b0;
    top->EQ = 0b0;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b0);
    EXPECT_EQ(top->ALUSrc, 0b0);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->PCSrc, 0b1);
    EXPECT_EQ(top->ALUctrl, 0b001);

}

TEST_F(ControlUnitTestbench, RWorksTest)
{
    top->op = 0b0110011;
    top->funct3 = 0b000;
    top->funct7_5 = 0b1;
    top->EQ = 0b0;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ALUSrc, 0b0);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->PCSrc, 0b0);
    EXPECT_EQ(top->ALUctrl, 0b001);

}
TEST_F(ControlUnitTestbench, LwWorksTest)
{
    top->op = 0b0000011;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0;
    top->EQ = 0b1;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ImmSrc, 0b00);
    EXPECT_EQ(top->ALUSrc, 0b1);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b1);
    EXPECT_EQ(top->PCSrc, 0b0);
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
