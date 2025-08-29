module TestAggregateAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../util.jl")

@testset "Aggregate Agents" begin
    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0)

    L = LightPSRIO.initialize([joinpath(@__DIR__, "..", "data")])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:aggregate_agents(BY_SUM(), "sum");
output1:save("output1");

local output2 = input1:aggregate_agents(BY_AVERAGE(), "avg");
output2:save("output2");

local output3 = input1:aggregate_agents(BY_MIN(), "min");
output3:save("output3");

local output4 = input1:aggregate_agents(BY_MAX(), "max");
output4:save("output4");
    """,
    )

    finalize(L)

    output1 = open_quiver("output1")
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [5.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [6.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [6.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [7.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 1) ≈ [6.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 2) ≈ [7.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 1) ≈ [7.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 2) ≈ [8.0]
    close_quiver(output1)

    output2 = open_quiver("output2")
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 1) ≈ [1.25]
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 2) ≈ [1.5]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 1) ≈ [1.5]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 2) ≈ [1.75]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 1) ≈ [1.5]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 2) ≈ [1.75]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 1) ≈ [1.75]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    close_quiver(output2)

    output3 = open_quiver("output3")
    @test Quiver.goto!(output3; stage = 1, scenario = 1, block = 1) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 1, block = 2) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 2, block = 1) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 1, scenario = 2, block = 2) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 1, block = 1) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 1, block = 2) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 2, block = 1) ≈ [1.0]
    @test Quiver.goto!(output3; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    close_quiver(output3)

    output4 = open_quiver("output4")
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 1) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 1, block = 2) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 1) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 1, scenario = 2, block = 2) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 1, block = 1) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 1, block = 2) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 2, block = 1) ≈ [2.0]
    @test Quiver.goto!(output4; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    close_quiver(output4)

    return nothing
end

end
