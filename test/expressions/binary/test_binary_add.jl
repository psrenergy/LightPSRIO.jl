module TestBinaryAdd

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Binary Add" begin
    setup_tests(
        create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "GWh"),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input1");
    
local output1 = 0.5 + input1;
output1:save("output1");
    
local output2 = input1 + 0.5;
output2:save("output2");
""",
        )

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

        return nothing
    end

    return nothing
end

end
