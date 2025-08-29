# module TestUnary

# using DataFrames
# using Dates
# using LightPSRIO
# using Quiver
# using Test

# include("../util.jl")

# @testset "Unary" begin
#     create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0)

#     L = LightPSRIO.initialize([joinpath(@__DIR__, "..", "data")])

#     LightPSRIO.run_script(
#         L,
#         """
# local generic = Generic();
# local input1 = generic:load("input1");

# local output1 = -input1;
# output1:save("output1");
#     """,
#     )

#     finalize(L)

#     create_quiver_tests("output1")

#     return nothing
# end

# end
