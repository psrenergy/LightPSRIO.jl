module TestBinary

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Binary" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = 0.5 + input1;
output1:save("output1");

local output2 = input1 + 0.5;
output2:save("output2");

local output3 = 1 - input1;
output3:save("output3");

local output4 = input1 - 1;
output4:save("output4");

local output5 = 2 * input1;
output5:save("output5");

local output6 = input1 * 2;
output6:save("output6");

local output7 = 2 / input1;
output7:save("output7");

local output8 = input1 / 2;
output8:save("output8");
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
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    end

    open_quiver("output2") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.5, 1.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.5, 1.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.5, 2.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [1.5, 2.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.5, 1.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [2.5, 1.5, 2.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [2.5, 2.5, 1.5, 2.5]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [2.5, 2.5, 2.5, 2.5]
    end

    open_quiver("output3") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, -1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, -1.0, -1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [0.0, -1.0, 0.0, -1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [0.0, -1.0, -1.0, -1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [-1.0, 0.0, 0.0, -1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [-1.0, 0.0, -1.0, -1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [-1.0, -1.0, 0.0, -1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [-1.0, -1.0, -1.0, -1.0]
    end

    open_quiver("output4") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [0.0, 0.0, 0.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [0.0, 0.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [0.0, 1.0, 0.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [0.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.0, 0.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    end

    open_quiver("output5") do q
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

    open_quiver("output6") do q
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

    open_quiver("output7") do q
        @test q.metadata.unit == "1/GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [2.0, 2.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [2.0, 2.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [2.0, 1.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [2.0, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.0, 2.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.0, 2.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 2.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    end

    open_quiver("output8") do q
        @test q.metadata.unit == "GWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [0.5, 0.5, 0.5, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [0.5, 0.5, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [0.5, 1.0, 0.5, 1.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 2) ≈ [0.5, 1.0, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [1.0, 0.5, 0.5, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 2) ≈ [1.0, 0.5, 1.0, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 1) ≈ [1.0, 1.0, 0.5, 1.0]
        @test Quiver.goto!(q; stage = 2, scenario = 2, block = 2) ≈ [1.0, 1.0, 1.0, 1.0]
    end

    delete_files(["output1", "output2", "output3", "output4", "output5", "output6", "output7", "output8", "output9", "output10"])

    return nothing
end

end
