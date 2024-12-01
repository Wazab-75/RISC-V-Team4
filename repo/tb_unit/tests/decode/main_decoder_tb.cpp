/*
 *  Verifies the results of the main decoder, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class MainDecoderbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->op = 0b0000000;
        // output: out
    }
};

TEST_F(MainDecoderbench, MainDecoder0WorksTest)
{
    top->op = 0b0000011;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ImmSrc, 0b00);
    EXPECT_EQ(top->ALUSrc, 0b1);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b1);
    EXPECT_EQ(top->Branch, 0b0);
    EXPECT_EQ(top->ALUOp, 0b00);
}

TEST_F(MainDecoderbench, MainDecoder1WorksTest)
{
    top->op = 0b0100011;    

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b0);
    EXPECT_EQ(top->ImmSrc, 0b01);
    EXPECT_EQ(top->ALUSrc, 0b1);
    EXPECT_EQ(top->MemWrite, 0b1);
    EXPECT_EQ(top->Branch, 0b0);
    EXPECT_EQ(top->ALUOp, 0b00);
}

TEST_F(MainDecoderbench, MainDecoder2WorksTest)
{
    top->op = 0b0110011;    

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b1);
    EXPECT_EQ(top->ALUSrc, 0b0);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->ResultSrc, 0b0);
    EXPECT_EQ(top->Branch, 0b0);
    EXPECT_EQ(top->ALUOp, 0b10);
}

TEST_F(MainDecoderbench, MainDecoder3WorksTest)
{
    top->op = 0b1100011;

    top->eval();

    EXPECT_EQ(top->RegWrite, 0b0);
    EXPECT_EQ(top->ImmSrc, 0b10);
    EXPECT_EQ(top->ALUSrc, 0b0);
    EXPECT_EQ(top->MemWrite, 0b0);
    EXPECT_EQ(top->Branch, 0b1);
    EXPECT_EQ(top->ALUOp, 0b01);
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
