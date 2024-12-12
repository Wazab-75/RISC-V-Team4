#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestMul)
{
    setupTest("1_mul");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 15);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
