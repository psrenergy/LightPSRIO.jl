module TestBinary

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("util.jl")

@testset "Binary" begin
    LightPSRIO.push_case!(raw"C:\Development\PSRIO\LightPSRIO.jl\test\data")

    # rand(0:9, 3, 2, 3, 4);

    data = [0 4; 6 7; 1 3;;; 8 4; 2 8; 9 5;;; 6 2; 5 4; 8 5;;;; 8 7; 8 6; 4 0;;; 2 1; 0 5; 9 1;;; 2 8; 8 8; 9 9;;;; 0 7; 9 7; 5 6;;; 5 9; 6 8; 8 2;;; 6 4; 8 8; 5 6;;;; 3 4; 0 9; 2 7;;; 8 1; 7 8; 3 8;;; 8 0; 3 3; 1 2]
    create_quiver("input1", data)

    data = [0 1;;; 5 4;;; 0 7;;;; 1 3;;; 2 4;;; 9 5;;;; 8 1;;; 6 3;;; 2 1;;;; 6 0;;; 8 0;;; 1 8]
    create_quiver("input2", data)

    data = [9; 2; 0;;; 4; 0; 8;;; 6; 1; 7;;;; 5; 7; 1;;; 5; 3; 8;;; 7; 9; 2;;;; 7; 0; 2;;; 5; 7; 9;;; 1; 8; 4;;;; 7; 9; 8;;; 7; 5; 2;;; 9; 6; 3]
    create_quiver("input3", data)

    data = [1 9; 3 1; 4 9;;;; 8 5; 2 6; 6 2;;;; 3 4; 1 5; 1 6;;;; 7 5; 1 6; 7 7]
    create_quiver("input4", data)

    data = [3 4; 2 2; 2 7;;; 8 3; 8 4; 1 1;;; 0 8; 3 7; 8 3;;;;]
    create_quiver("input5", data)

    L = LightPSRIO.initialize()

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");
local input2 = generic:load("input2");
local input3 = generic:load("input3");
local input4 = generic:load("input4");
local input5 = generic:load("input5");

local output1 = input1 + input1;
output1:save("output1");

local output2 = input1 * input3;
output2:save("output2");
    """,
    )

    finalize(L)

    output1 = load_quiver("output1")
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 1) ≈ [0.0, 12.0, 2.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 1, block = 2) ≈ [8.0, 14.0, 6.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 1) ≈ [16.0, 4.0, 18.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 2, block = 2) ≈ [8.0, 16.0, 10.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 3, block = 1) ≈ [12.0, 10.0, 16.0]
    @test Quiver.goto!(output1; stage = 1, scenario = 3, block = 2) ≈ [4.0, 8.0, 10.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 1) ≈ [16.0, 16.0, 8.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 1, block = 2) ≈ [14.0, 12.0, 0.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 1) ≈ [4.0, 0.0, 18.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 2, block = 2) ≈ [2.0, 10.0, 2.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 3, block = 1) ≈ [4.0, 16.0, 18.0]
    @test Quiver.goto!(output1; stage = 2, scenario = 3, block = 2) ≈ [16.0, 16.0, 18.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 1, block = 1) ≈ [0.0, 18.0, 10.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 1, block = 2) ≈ [14.0, 14.0, 12.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 2, block = 1) ≈ [10.0, 12.0, 16.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 2, block = 2) ≈ [18.0, 16.0, 4.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 3, block = 1) ≈ [12.0, 16.0, 10.0]
    @test Quiver.goto!(output1; stage = 3, scenario = 3, block = 2) ≈ [8.0, 16.0, 12.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 1, block = 1) ≈ [6.0, 0.0, 4.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 1, block = 2) ≈ [8.0, 18.0, 14.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 2, block = 1) ≈ [16.0, 14.0, 6.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 2, block = 2) ≈ [2.0, 16.0, 16.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 3, block = 1) ≈ [16.0, 6.0, 2.0]
    @test Quiver.goto!(output1; stage = 4, scenario = 3, block = 2) ≈ [0.0, 6.0, 4.0]
    Quiver.close!(output1)

    output2 = load_quiver("output2")
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 1) ≈ [0.0, 12.0, 0.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 1, block = 2) ≈ [36.0, 14.0, 0.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 1) ≈ [32.0, 0.0, 72.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 2, block = 2) ≈ [16.0, 0.0, 40.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 3, block = 1) ≈ [36.0, 5.0, 56.0]
    @test Quiver.goto!(output2; stage = 1, scenario = 3, block = 2) ≈ [12.0, 4.0, 35.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 1) ≈ [40.0, 56.0, 4.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 1, block = 2) ≈ [35.0, 42.0, 0.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 1) ≈ [10.0, 0.0, 72.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 2, block = 2) ≈ [5.0, 15.0, 8.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 3, block = 1) ≈ [14.0, 72.0, 18.0]
    @test Quiver.goto!(output2; stage = 2, scenario = 3, block = 2) ≈ [56.0, 72.0, 18.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 1, block = 1) ≈ [0.0, 0.0, 10.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 1, block = 2) ≈ [49.0, 0.0, 12.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 2, block = 1) ≈ [25.0, 42.0, 72.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 2, block = 2) ≈ [45.0, 56.0, 18.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 3, block = 1) ≈ [6.0, 64.0, 20.0]
    @test Quiver.goto!(output2; stage = 3, scenario = 3, block = 2) ≈ [4.0, 64.0, 24.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 1, block = 1) ≈ [21.0, 0.0, 16.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 1, block = 2) ≈ [28.0, 81.0, 56.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 2, block = 1) ≈ [56.0, 35.0, 6.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 2, block = 2) ≈ [7.0, 40.0, 16.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 3, block = 1) ≈ [72.0, 18.0, 3.0]
    @test Quiver.goto!(output2; stage = 4, scenario = 3, block = 2) ≈ [0.0, 18.0, 6.0]
    Quiver.close!(output2)

    return nothing
end

end
