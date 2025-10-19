module TestRenameAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Rename Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:rename_agents({ "agent_A", "agent_B", "agent_C", "agent_D" });
output1:save("output1");
    """,
    )

    finalize(L)

    open_quiver("output1") do q
        @test q.metadata.frequency == "month"
        # @test q.metadata.initial_date == DateTime("2025-10-12T23:20:23")
        @test q.metadata.number_of_dimensions == 3
        @test q.metadata.dimensions == [:stage, :scenario, :block]
        @test q.metadata.time_dimension == :stage
        @test q.metadata.unit == "GWh"
        @test q.metadata.dimension_size == [2, 2, 2]
        @test q.metadata.number_of_time_series == 4
        @test q.metadata.labels == ["agent_A", "agent_B", "agent_C", "agent_D"]

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

end
