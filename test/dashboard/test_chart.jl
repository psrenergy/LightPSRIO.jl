module TestLayers

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Layers" begin
    path = get_data_directory()

    @show expression = LightPSRIO.ExpressionDataQuiver(path, "input1")

    layer = LightPSRIO.Layer()

    return nothing
end

end
