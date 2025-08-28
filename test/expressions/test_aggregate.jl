module TestAggregate

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../util.jl")

@testset "Aggregate" begin
    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0)

    L = LightPSRIO.initialize([raw"C:\Development\PSRIO\LightPSRIO.jl\test\data"])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:aggregate("stage", BY_SUM());
output1:save("output1");

local output2 = input1:aggregate("scenario", BY_SUM());
output2:save("output2");

local output3 = input1:aggregate("block", BY_SUM());
output3:save("output3");

local output4 = input1:aggregate("stage", BY_AVERAGE());
output4:save("output4");

local output5 = input1:aggregate("scenario", BY_AVERAGE());
output5:save("output5");

local output6 = input1:aggregate("block", BY_AVERAGE());
output6:save("output6");
    """,
    )

    finalize(L)

    input1 = open_quiver("input1")
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
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [3.0, 2.0, 2.0, 4.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [3.0, 2.0, 4.0, 4.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [3.0, 4.0, 2.0, 4.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [3.0, 4.0, 4.0, 4.0]
    close_quiver(output1)

    output2 = open_quiver("output2")
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 1) ≈ [2.0, 3.0, 2.0, 4.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 2) ≈ [2.0, 3.0, 4.0, 4.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 1) ≈ [4.0, 3.0, 2.0, 4.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 2) ≈ [4.0, 3.0, 4.0, 4.0]
    close_quiver(output2)

    output3 = open_quiver("output3")
    @test Quiver.goto!(output3; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 3.0, 4.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 3.0, 4.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 3.0, 4.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 3.0, 4.0]
    close_quiver(output3)

    output4 = open_quiver("output4")
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.0, 1.0, 2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.0, 2.0, 2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.0, 1.0, 2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.0, 2.0, 2.0]
    close_quiver(output4)

    output5 = open_quiver("output5")
    @test Quiver.goto!(output5; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output5; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.5, 2.0, 2.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output5; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.5, 2.0, 2.0]
    close_quiver(output5)

    output6 = open_quiver("output6")
    @test Quiver.goto!(output6; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.5, 2.0]
    @test Quiver.goto!(output6; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.5, 2.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.5, 2.0]
    @test Quiver.goto!(output6; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.5, 2.0]
    close_quiver(output6)

    return nothing
end

end
