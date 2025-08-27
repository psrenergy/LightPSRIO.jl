module TestBinary

using Dates
using LightPSRIO
using Quiver
using Test

include("util.jl")

@testset "Binary" begin
    LightPSRIO.push_case!(raw"C:\Development\PSRIO\LightPSRIO.jl\test")

    file1 = create_quiver(n_stages=10, n_scenarios=12, n_blocks=3)
    file2 = "$(file1)_copy"

    L = LightPSRIO.initialize()

    LightPSRIO.run_script(L, """
local generic = Generic();
generic:load("$file1"):save("$file2");
    """)

    finalize(L)

    verify_quiver(file2; n_stages=10, n_scenarios=12, n_blocks=3, n_agents=3)

    return nothing
end

end