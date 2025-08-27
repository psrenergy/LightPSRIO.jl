module TestBinary

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("util.jl")

@testset "Binary" begin
    LightPSRIO.push_case!(raw"C:\Development\PSRIO\LightPSRIO.jl\test")

    data = [
        4 2; 6 3; 5 1;;; 8 6; 3 4; 7 1;;; 4 2; 6 1; 5 3;;;;
        6 1; 4 8; 4 5;;; 9 9; 8 1; 8 2;;; 8 6; 2 2; 3 2;;;;
        0 7; 0 7; 1 8;;; 1 6; 2 7; 0 6;;; 8 3; 1 5; 3 5;;;;
        0 1; 7 3; 6 2;;; 8 3; 1 2; 9 8;;; 1 4; 6 0; 7 7
    ]
    create_quiver("input1", data)

    data = [
        2 1; 9 6; 4 9;;;;
        9 1; 1 5; 4 4;;;;
        4 5; 2 9; 0 5;;;;
        5 5; 5 8; 6 5
    ]
    create_quiver("input2", data)

    L = LightPSRIO.initialize()

    LightPSRIO.run_script(L, """
local generic = Generic();
local exp1 = generic:load("input1");
local exp2 = generic:load("input2");
local exp3 = exp1 + exp2;
exp3:save("output1");
    """)

    finalize(L)

#     verify_quiver(file2; n_stages=10, n_scenarios=12, n_blocks=3, n_agents=3)

    return nothing
end

end