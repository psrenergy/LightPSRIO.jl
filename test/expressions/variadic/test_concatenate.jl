module TestConcatenate

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
local input1 = generic:load("input_month_2t_2s_2b");

local output1 = concatenate({input1, input1, input1, input1});
output1:save("output1");
    """,
    )

    finalize(L)

    create_quiver_tests("output1")

    # delete_files(["output1"])

    return nothing
end

end
