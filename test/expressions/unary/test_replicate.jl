module TestReplicate

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Convert" begin
    setup_tests(
        create_quiver("input2"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month"),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input2");

local output1 = input1:replicate("stage", 4);
output1:save("output1");
    """,
        )

        open_quiver("output1") do q
            @test q.metadata.frequency == "month"
            # @test q.metadata.initial_date == DateTime("2024-01-01T00:00:00")
            @test q.metadata.number_of_dimensions == 3
            @test q.metadata.dimensions == [:stage, :scenario, :block]
            @test q.metadata.time_dimension == :stage
            @test q.metadata.unit == ""
            @test q.metadata.dimension_size == [8, 2, 2]
            @test q.metadata.number_of_time_series == 4
            @test q.metadata.labels == ["data_stage", "data_scenario", "data_block", "data_constant"]

            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 3, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 3, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 3, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 3, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 4, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 4, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 4, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 4, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 5, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 5, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 5, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 5, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 6, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 6, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 6, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 6, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 7, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 7, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 7, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 7, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 8, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 8, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
            @test Quiver.goto!(q; stage = 8, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
            @test Quiver.goto!(q; stage = 8, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
        end

        return nothing
    end

    return nothing
end

end
