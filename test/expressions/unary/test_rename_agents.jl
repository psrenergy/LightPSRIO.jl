module TestRenameAgents

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

@testset "Rename Agents" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

local output1 = input1:rename_agents({ "agent_A", "agent_B", "agent_C", "agent_D" });
output1:save("output1");
    """,
    )

    finalize(L)

   create_quiver_tests("output1")

    delete_files(["output1"])

    return nothing
end

end
