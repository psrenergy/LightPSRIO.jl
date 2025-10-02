# module TestLayer

# using Dates
# using LightPSRIO
# using Test

# @testset "Layer" begin
#     series = LightPSRIO.Layer(
#         "Test Series",
#         LightPSRIO.SeriesType.Line,
#         LightPSRIO.DateReference(LightPSRIO.StageType.WEEK, 2, 2000),
#     )

#     LightPSRIO.add(series, 1, 10.0)
#     LightPSRIO.add(series, 2, 20.0)

#     @show LightPSRIO.encode_echarts(series)
#     @show LightPSRIO.encode_highcharts(series)

#     return nothing
# end

# end
