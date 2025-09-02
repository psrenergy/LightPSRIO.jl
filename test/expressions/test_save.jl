module TestSave

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Save" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

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

    @test !isfile(joinpath(get_data_directory(), "output1"))

    return nothing
end

end
