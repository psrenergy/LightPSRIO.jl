module TestBinary

using DataFrames
using Dates
using LightPSRIO
using Retry
using Quiver
using Test

include("../../conftest.jl")

@testset "Binary" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = 0.5 + input1;
output1:save("output1");

local output2 = input1 + 0.5;
output2:save("output2");

local output3 = 1 - input1;
output3:save("output3");

local output4 = input1 - 1;
output4:save("output4");

local output5 = 2 * input1;
output5:save("output5");

local output6 = input1 * 2;
output6:save("output6");

local output7 = 2 / input1;
output7:save("output7");

local output8 = input1 / 2;
output8:save("output8");

local output9 = input1 ^ 2;
output9:save("output9");

local output10 = 2 ^ input1;
output10:save("output10");
    """,
    )

    finalize(L)

    input1 = open_quiver("input1")
    @test input1.metadata.unit == "GWh"
    @test Quiver.goto!(input1; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
    @test Quiver.goto!(input1; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
    @test Quiver.goto!(input1; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
    @test Quiver.goto!(input1; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
    @test Quiver.goto!(input1; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
    @test Quiver.goto!(input1; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
    @test Quiver.goto!(input1; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
    @test Quiver.goto!(input1; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
    close_quiver(input1)

    output1 = open_quiver("output1")
    @test output1.metadata.unit == "GWh"
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    close_quiver(output1)

    output2 = open_quiver("output2")
    @test output2.metadata.unit == "GWh"
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    close_quiver(output2)

    output3 = open_quiver("output3")
    @test output3.metadata.unit == "GWh"
    @test Quiver.goto!(output3; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, -1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, -1.0, -1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 2, block = 1) ≈ [0.0, -1.0, 0.0, -1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 2, block = 2) ≈ [0.0, -1.0, -1.0, -1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 1, block = 1) ≈ [-1.0, 0.0, 0.0, -1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 1, block = 2) ≈ [-1.0, 0.0, -1.0, -1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 2, block = 1) ≈ [-1.0, -1.0, 0.0, -1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 2, block = 2) ≈ [-1.0, -1.0, -1.0, -1.0]
    close_quiver(output3)

    output4 = open_quiver("output4")
    @test output4.metadata.unit == "GWh"
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, 1.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, 1.0, 1.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 1) ≈ [0.0, 1.0, 0.0, 1.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 2) ≈ [0.0, 1.0, 1.0, 1.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.0, 0.0, 1.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.0, 1.0, 1.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.0, 1.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    close_quiver(output4)

    output5 = open_quiver("output5")
    @test output5.metadata.unit == "GWh"
    @test Quiver.goto!(output5; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output5; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output5; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output5; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    close_quiver(output5)

    output6 = open_quiver("output6")
    @test output6.metadata.unit == "GWh"
    @test Quiver.goto!(output6; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output6; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output6; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output6; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    close_quiver(output6)

    output7 = open_quiver("output7")
    @test output7.metadata.unit == "GWh"
    @test Quiver.goto!(output7; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 1.0]
    @test Quiver.goto!(output7; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 1.0, 1.0]
    @test Quiver.goto!(output7; stage = 1, scenario = 2, block = 1) ≈ [2.0, 1.0, 2.0, 1.0]
    @test Quiver.goto!(output7; stage = 1, scenario = 2, block = 2) ≈ [2.0, 1.0, 1.0, 1.0]
    @test Quiver.goto!(output7; stage = 2, scenario = 1, block = 1) ≈ [1.0, 2.0, 2.0, 1.0]
    @test Quiver.goto!(output7; stage = 2, scenario = 1, block = 2) ≈ [1.0, 2.0, 1.0, 1.0]
    @test Quiver.goto!(output7; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 2.0, 1.0]
    @test Quiver.goto!(output7; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    close_quiver(output7)

    output8 = open_quiver("output8")
    @test output8.metadata.unit == "GWh"
    @test Quiver.goto!(output8; stage = 1, scenario = 1, block = 1) ≈ [0.5, 0.5, 0.5, 1.0]
    @test Quiver.goto!(output8; stage = 1, scenario = 1, block = 2) ≈ [0.5, 0.5, 1.0, 1.0]
    @test Quiver.goto!(output8; stage = 1, scenario = 2, block = 1) ≈ [0.5, 1.0, 0.5, 1.0]
    @test Quiver.goto!(output8; stage = 1, scenario = 2, block = 2) ≈ [0.5, 1.0, 1.0, 1.0]
    @test Quiver.goto!(output8; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.5, 0.5, 1.0]
    @test Quiver.goto!(output8; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.5, 1.0, 1.0]
    @test Quiver.goto!(output8; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.5, 1.0]
    @test Quiver.goto!(output8; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    close_quiver(output8)

    output9 = open_quiver("output9")
    @test output9.metadata.unit == "GWh"
    @test Quiver.goto!(output9; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 4.0]
    @test Quiver.goto!(output9; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 4.0, 4.0]
    @test Quiver.goto!(output9; stage = 1, scenario = 2, block = 1) ≈ [1.0, 4.0, 1.0, 4.0]
    @test Quiver.goto!(output9; stage = 1, scenario = 2, block = 2) ≈ [1.0, 4.0, 4.0, 4.0]
    @test Quiver.goto!(output9; stage = 2, scenario = 1, block = 1) ≈ [4.0, 1.0, 1.0, 4.0]
    @test Quiver.goto!(output9; stage = 2, scenario = 1, block = 2) ≈ [4.0, 1.0, 4.0, 4.0]
    @test Quiver.goto!(output9; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 1.0, 4.0]
    @test Quiver.goto!(output9; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    close_quiver(output9)

    output10 = open_quiver("output10")
    @test output10.metadata.unit == "GWh"
    @test Quiver.goto!(output10; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output10; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output10; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output10; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
    @test Quiver.goto!(output10; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output10; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output10; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output10; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    close_quiver(output10)

    finalize_tests()

    return nothing
end

end
