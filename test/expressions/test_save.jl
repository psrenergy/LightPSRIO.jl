module TestSave

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Save" begin
    setup_tests() do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input_nonexistent");

local output1 = input1;
output1:save("output1");
    """,
        )

        @test !isfile(joinpath(get_data_directory(), "output1"))

        return nothing
    end

    return nothing
end

end
