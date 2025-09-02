module TestAggregateDimensions

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Aggregate Dimensions" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:aggregate("stage", BY_SUM());
output1:save("output1");

local output2 = input1:aggregate("scenario", BY_SUM());
output2:save("output2");

local output3 = input1:aggregate("block", BY_SUM());
output3:save("output3");

local output4 = input1:aggregate("stage", BY_AVERAGE());
output4:save("output4");

local output5 = input1:aggregate("scenario", BY_AVERAGE());
output5:save("output5");

local output6 = input1:aggregate("block", BY_AVERAGE());
output6:save("output6");
    """,
    )

    finalize(L)

    open_quiver("input1") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.0, 2.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.0, 2.0, 2.0, 2.0]
    end

    open_quiver("output1") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [3.0, 2.0, 2.0, 4.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [3.0, 2.0, 4.0, 4.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [3.0, 4.0, 2.0, 4.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [3.0, 4.0, 4.0, 4.0]
    end

    open_quiver("output2") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0, 3.0, 2.0, 4.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [2.0, 3.0, 4.0, 4.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [4.0, 3.0, 2.0, 4.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [4.0, 3.0, 4.0, 4.0]
    end

    open_quiver("output3") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 3.0, 4.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0, 4.0, 3.0, 4.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [4.0, 2.0, 3.0, 4.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [4.0, 4.0, 3.0, 4.0]
    end

    open_quiver("output4") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.0, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.0, 2.0, 2.0]
    end

    open_quiver("output5") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.5, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.5, 2.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.5, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.0, 1.5, 2.0, 2.0]
    end

    open_quiver("output6") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.5, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.5, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 1.0, 1.5, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.0, 2.0, 1.5, 2.0]
    end

    finalize_tests()

    return nothing
end

end
