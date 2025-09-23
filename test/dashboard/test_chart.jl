module TestLayers

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Layers" begin
    @show path = get_data_directory()

    @show expression = LightPSRIO.ExpressionDataQuiver(path, "input1")

    chart = LightPSRIO.Highcharts("Test Chart")
    LightPSRIO.add(chart, expression)

    tab = LightPSRIO.Tab("Tab")
    LightPSRIO.push(tab, chart)

    dashboard = LightPSRIO.Dashboard()
    LightPSRIO.push(dashboard, tab)
    LightPSRIO.save(dashboard, path, "test_layers")

    return nothing
end

end
