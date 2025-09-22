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

    chart = LightPSRIO.ChartJS("Test Chart")

    LightPSRIO.add(chart, expression)

    @show chart

    return nothing
end

end
