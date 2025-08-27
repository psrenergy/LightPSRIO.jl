module TestBinary

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("util.jl")

@testset "Binary" begin
    LightPSRIO.push_case!(raw"C:\Development\PSRIO\LightPSRIO.jl\test\data")

    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0)

    L = LightPSRIO.initialize()

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
    """,
    )

    finalize(L)

    output1 = load_quiver("output1")
    Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
    Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
    Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
    Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
    Quiver.goto!(output1; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
    Quiver.goto!(output1; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
    Quiver.goto!(output1; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
    Quiver.goto!(output1; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    Quiver.close!(output1)

    output2 = load_quiver("output2")
    Quiver.goto!(output2; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
    Quiver.goto!(output2; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
    Quiver.goto!(output2; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
    Quiver.goto!(output2; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
    Quiver.goto!(output2; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
    Quiver.goto!(output2; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
    Quiver.goto!(output2; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
    Quiver.goto!(output2; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    Quiver.close!(output2)

    output3 = load_quiver("output3")
    Quiver.goto!(output3; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, -1.0]
    Quiver.goto!(output3; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, -1.0, -1.0]
    Quiver.goto!(output3; stage = 1, scenario = 2, block = 1) ≈ [0.0, -1.0, 0.0, -1.0]
    Quiver.goto!(output3; stage = 1, scenario = 2, block = 2) ≈ [0.0, -1.0, -1.0, -1.0]
    Quiver.goto!(output3; stage = 2, scenario = 1, block = 1) ≈ [-1.0, 0.0, 0.0, -1.0]
    Quiver.goto!(output3; stage = 2, scenario = 1, block = 2) ≈ [-1.0, 0.0, -1.0, -1.0]
    Quiver.goto!(output3; stage = 2, scenario = 2, block = 1) ≈ [-1.0, -1.0, 0.0, -1.0]
    Quiver.goto!(output3; stage = 2, scenario = 2, block = 2) ≈ [-1.0, -1.0, -1.0, -1.0]
    Quiver.close!(output3)

    output4 = load_quiver("output4")
    Quiver.goto!(output4; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, 1.0]
    Quiver.goto!(output4; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, 1.0, 1.0]
    Quiver.goto!(output4; stage = 1, scenario = 2, block = 1) ≈ [0.0, 1.0, 0.0, 1.0]
    Quiver.goto!(output4; stage = 1, scenario = 2, block = 2) ≈ [0.0, 1.0, 1.0, 1.0]
    Quiver.goto!(output4; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.0, 0.0, 1.0]
    Quiver.goto!(output4; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.0, 1.0, 1.0]
    Quiver.goto!(output4; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.0, 1.0]
    Quiver.goto!(output4; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    Quiver.close!(output4)

    output5 = load_quiver("output5")
    Quiver.goto!(output5; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
    Quiver.goto!(output5; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
    Quiver.goto!(output5; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
    Quiver.goto!(output5; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
    Quiver.goto!(output5; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
    Quiver.goto!(output5; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
    Quiver.goto!(output5; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
    Quiver.goto!(output5; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    Quiver.close!(output5)

    output6 = load_quiver("output6")
    Quiver.goto!(output6; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
    Quiver.goto!(output6; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
    Quiver.goto!(output6; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
    Quiver.goto!(output6; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
    Quiver.goto!(output6; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
    Quiver.goto!(output6; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
    Quiver.goto!(output6; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
    Quiver.goto!(output6; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
    Quiver.close!(output6)

    output7 = load_quiver("output7")
    Quiver.goto!(output7; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 1.0]
    Quiver.goto!(output7; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 1.0, 1.0]
    Quiver.goto!(output7; stage = 1, scenario = 2, block = 1) ≈ [2.0, 1.0, 2.0, 1.0]
    Quiver.goto!(output7; stage = 1, scenario = 2, block = 2) ≈ [2.0, 1.0, 1.0, 1.0]
    Quiver.goto!(output7; stage = 2, scenario = 1, block = 1) ≈ [1.0, 2.0, 2.0, 1.0]
    Quiver.goto!(output7; stage = 2, scenario = 1, block = 2) ≈ [1.0, 2.0, 1.0, 1.0]
    Quiver.goto!(output7; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 2.0, 1.0]
    Quiver.goto!(output7; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    Quiver.close!(output7)

    output8 = load_quiver("output8")
    Quiver.goto!(output8; stage = 1, scenario = 1, block = 1) ≈ [0.5, 0.5, 0.5, 1.0]
    Quiver.goto!(output8; stage = 1, scenario = 1, block = 2) ≈ [0.5, 0.5, 1.0, 1.0]
    Quiver.goto!(output8; stage = 1, scenario = 2, block = 1) ≈ [0.5, 1.0, 0.5, 1.0]
    Quiver.goto!(output8; stage = 1, scenario = 2, block = 2) ≈ [0.5, 1.0, 1.0, 1.0]
    Quiver.goto!(output8; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.5, 0.5, 1.0]
    Quiver.goto!(output8; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.5, 1.0, 1.0]
    Quiver.goto!(output8; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.5, 1.0]
    Quiver.goto!(output8; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    Quiver.close!(output8)

    # create_tests("output1")
    # create_tests("output2")
    # create_tests("output3")
    # create_tests("output4")
    # create_tests("output5")
    # create_tests("output6")
    # create_tests("output7")
    # create_tests("output8")

    return nothing
end

end
