module TestConvert

using DataFrames
using Dates
using LightPSRIO
using Retry
using Quiver
using Test

include("../../conftest.jl")

@testset "Convert" begin
    initialize_tests()
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
    finalize_tests()

    return nothing
end

end
