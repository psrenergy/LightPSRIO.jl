module TestSelectAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Select Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:select_agents({ 4 });
output1:save("output1");

local output2 = input1:select_agents({ 2, 3 });
output2:save("output2");
    """,
    )

    finalize(L)

    create_quiver_tests("output1")
    create_quiver_tests("output2")
    create_quiver_tests("output3")

    return nothing
end

end
