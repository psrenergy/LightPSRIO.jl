module TestAggregateAgents

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

    open_quiver("output1") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [5.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [6.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [6.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [7.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [6.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [7.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [7.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [8.0]
    end

    open_quiver("output2") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.25]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.75]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.5]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.75]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [1.75]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    end

    open_quiver("output3") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    end

    open_quiver("output4") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0]
    end
    
    delete_files(["output1", "output2", "output3", "output4"])

    return nothing
end

end
