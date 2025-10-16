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
local input1 = generic:load("input_month_36t_1s_1b");

local output1 = input1:year_profile(BY_MIN());
output1:save("output1");

local output2 = input1:year_profile(BY_MAX());
output2:save("output2");
    """,
    )

    finalize(L)

    create_quiver_tests("input3")
    create_quiver_tests("output1")
    create_quiver_tests("output2")

    delete_files(["output1"])

    return nothing
end

end
