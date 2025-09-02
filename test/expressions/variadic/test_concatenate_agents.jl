module TestConcatenateAgents

using DataFrames
using Dates
using LightPSRIO
using Retry
using Quiver
using Test

include("../../conftest.jl")

@testset "Concatenate Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

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
output1:save("output3");

local output2 = concatenate_agents(input1, input2);
output2:save("output4");
    """,
    )

    finalize(L)

    output = open_quiver("output3")
    @test output.metadata.labels == ["sum", "avg", "min", "max"]
    @test Quiver.goto!(output; stage = 1, scenario = 1, block = 1) ≈ [5.0, 1.25, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 1, block = 2) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 2, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 2, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 1, block = 1) ≈ [6.0, 1.5, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 1, block = 2) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 2, block = 1) ≈ [7.0, 1.75, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 2, block = 2) ≈ [8.0, 2.0, 2.0, 2.0]
    close_quiver(output)

    output = open_quiver("output4")
    @test Quiver.goto!(output; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
    @test Quiver.goto!(output; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
    close_quiver(output)

    finalize_tests()

    return nothing
end

end
