module TestBinaryMul

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Binary Mul" begin
    setup_tests(
        create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "GWh"),
        create_quiver("input2"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "MW"),
        create_quiver("input3"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "hour"),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input1");
local input2 = generic:load("input2");
local input3 = generic:load("input3");

local output1 = 2 * input1;
output1:save("output1");

local output2 = input1 * 2;
output2:save("output2");

local output3 = input2 * input3;
output3:save("output3");
    """,
        )

        open_quiver("output1") do q
            @test q.metadata.unit == "GWh"
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
        end

        open_quiver("output2") do q
            @test q.metadata.unit == "GWh"
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [2.0, 4.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [4.0, 2.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 2.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
        end

        open_quiver("output3") do q
            @test q.metadata.frequency == "month"
            @test q.metadata.initial_date == DateTime("2024-01-01T00:00:00")
            @test q.metadata.number_of_dimensions == 3
            @test q.metadata.dimensions == [:stage, :scenario, :block]
            @test q.metadata.time_dimension == :stage
            @test q.metadata.unit == "MWh"
            @test q.metadata.dimension_size == [2, 2, 2]
            @test q.metadata.number_of_time_series == 4
            @test q.metadata.labels == ["data_stage", "data_scenario", "data_block", "data_constant"]

            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 4.0, 1.0, 4.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 4.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [4.0, 1.0, 1.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [4.0, 1.0, 4.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 1.0, 4.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [4.0, 4.0, 4.0, 4.0]
        end

        return nothing
    end

    return nothing
end

end
