module TestBinaryDiv

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Binary Div" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input_month_2t_2s_2b_GWh");

local output1 = 2 / input1;
output1:save("output1");

local output2 = input1 / 2;
output2:save("output2");
    """,
    )

    finalize(L)

    open_quiver("output1") do q
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

    open_quiver("output2") do q
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

    return nothing
end

end
