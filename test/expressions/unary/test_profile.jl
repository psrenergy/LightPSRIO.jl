module TestProfile

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Aggregate Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input_month_36t_1s_1b");

local output1 = input1:year_profile(BY_MIN());
output1:save("output1");

local output2 = input1:year_profile(BY_MAX());
output2:save("output2");
    """,
    )

    finalize(L)

    open_quiver("output1") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2024-01-01T00:00:00")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == ""
        @test q.metadata.dimension_size == [12, 1, 1]
        @test q.metadata.number_of_time_series == 4
        @test q.metadata.labels == ["data_stage", "data_scenario", "data_block", "data_constant"]

        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 3, scenario = 1, block = 1) ≈ [3.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 4, scenario = 1, block = 1) ≈ [4.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 5, scenario = 1, block = 1) ≈ [5.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 6, scenario = 1, block = 1) ≈ [6.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 7, scenario = 1, block = 1) ≈ [7.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 8, scenario = 1, block = 1) ≈ [8.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 9, scenario = 1, block = 1) ≈ [9.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 10, scenario = 1, block = 1) ≈ [10.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 11, scenario = 1, block = 1) ≈ [11.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 12, scenario = 1, block = 1) ≈ [12.0, 1.0, 1.0, 1.0]
    end

    open_quiver("output2") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2024-01-01T00:00:00")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == ""
        @test q.metadata.dimension_size == [12, 1, 1]
        @test q.metadata.number_of_time_series == 4
        @test q.metadata.labels == ["data_stage", "data_scenario", "data_block", "data_constant"]

        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [25.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [26.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 3, scenario = 1, block = 1) ≈ [27.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 4, scenario = 1, block = 1) ≈ [28.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 5, scenario = 1, block = 1) ≈ [29.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 6, scenario = 1, block = 1) ≈ [30.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 7, scenario = 1, block = 1) ≈ [31.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 8, scenario = 1, block = 1) ≈ [32.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 9, scenario = 1, block = 1) ≈ [33.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 10, scenario = 1, block = 1) ≈ [34.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 11, scenario = 1, block = 1) ≈ [35.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 12, scenario = 1, block = 1) ≈ [36.0, 1.0, 1.0, 1.0]
    end

    delete_files(["output1", "output2"])

    return nothing
end

end
