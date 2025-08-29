module TestAggregateAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../util.jl")

@testset "Concatenate Agents" begin
    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0)

    L = LightPSRIO.initialize([joinpath(@__DIR__, "..", "data")])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");
local input2 = input1:aggregate_agents(BY_SUM(), "sum");
local input3 = input1:aggregate_agents(BY_AVERAGE(), "avg");
local input4 = input1:aggregate_agents(BY_MIN(), "min");
local input5 = input1:aggregate_agents(BY_MAX(), "max");

local output1 = concatenate_agents(input2, input3, input4, input5);
output1:save("output1");
    """,
    )

    finalize(L)

    output1 = open_quiver("output1")
    @test output1.metadata.labels == ["sum", "avg", "min", "max"]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [5.0, 1.25, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 1) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 2) ≈ [8.0, 2.0, 2.0, 2.0]
    close_quiver(output1)

    return nothing
end

end
