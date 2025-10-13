module TestSelectAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Select Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:select_agents({ 1, 2, 3 });
output1:save("output1");

local output2 = input1:select_agents({ "data_scenario", "data_block", "data_constant" });
output2:save("output2");

local output3 = input1:select_agents({ "data_stage", 4 });
output3:save("output3");
    """,
    )

    finalize(L)

    open_quiver("output1") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2025-10-12T23:17:37")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == "GWh"
        @test q.metadata.dimension_size == [2, 2, 2]
        @test q.metadata.number_of_time_series == 3
        @test q.metadata.labels == ["data_stage", "data_scenario", "data_block"]

        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0]
    end

    open_quiver("output2") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2025-10-12T23:17:38")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == "GWh"
        @test q.metadata.dimension_size == [2, 2, 2]
        @test q.metadata.number_of_time_series == 3
        @test q.metadata.labels == ["data_scenario", "data_block", "data_constant"]

        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0]
    end

    open_quiver("output3") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2025-10-12T23:17:38")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == "GWh"
        @test q.metadata.dimension_size == [2, 2, 2]
        @test q.metadata.number_of_time_series == 2
        @test q.metadata.labels == ["data_stage", "data_constant"]

        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0]
    end

    delete_files(["output1", "output2", "output3"])

    return nothing
end

end
