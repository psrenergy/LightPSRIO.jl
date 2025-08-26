module TestExample1

using LightPSRIO
using Test

@testset "Example 1" begin
    L = LightPSRIO.initialize()

    run_file(L, joinpath(@__DIR__, "test_example1.lua"))

    finalize(L)

    return nothing
end

end