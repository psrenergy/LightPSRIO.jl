module TestProfileDimensions

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Aggregate Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input3 = generic:load("input3");

local output1 = input3:year_profile(BY_MAX());
output1:save("output1");

local output2 = input3:year_profile(BY_MIN());
output2:save("output2");
    """,
    )

    finalize(L)

    create_quiver_tests("input3")
    create_quiver_tests("output1")

    delete_files(["output1"])

    return nothing
end

end
