module TestCollection

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../util.jl")

@testset "Collection" begin
    L = LightPSRIO.initialize([joinpath(@__DIR__, "..", "data")])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input_nonexistent");

local output1 = input1;
output1:save("output1");
    """,
    )

    finalize(L)


    return nothing
end

end
