module TestConvert

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../util.jl")

@testset "Convert" begin
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input_nonexistent");

local output1 = input1:convert("MWh");
output1:save("output1");
    """,
    )

    finalize(L)

    return nothing
end

end
