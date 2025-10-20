module TestConcatenateAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Concatenate Agents" begin
    setup_tests(
        create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "GWh"),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input1");
local input2 = generic:load("input_nonexistent");

local input1_sum = input1:aggregate_agents(BY_SUM(), "sum");
local input1_avg = input1:aggregate_agents(BY_AVERAGE(), "avg");
local input1_min = input1:aggregate_agents(BY_MIN(), "min");
local input1_max = input1:aggregate_agents(BY_MAX(), "max");

local output1 = concatenate_agents(input1_sum, input1_avg, input1_min, input1_max);
output1:save("output1");

local output2 = concatenate_agents(input1, input2);
output2:save("output2");
    """,
        )

        open_quiver("output1") do q
            @test q.metadata.labels == ["sum", "avg", "min", "max"]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [5.0, 1.25, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [6.0, 1.5, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [7.0, 1.75, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [8.0, 2.0, 2.0, 2.0]
        end

        open_quiver("output2") do q
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
        end

        return nothing
    end

    return nothing
end

end
