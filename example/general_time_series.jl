import Pkg
Pkg.instantiate()

using LightPSRIO

path = raw"C:\Development\SIAM2\SIAM26\GeneralTimeSeriesApproximationInSDDP.jl\data"
script_path = raw"C:\Development\SIAM\LightPSRIO.jl\example\general_time_series.lua"

L = LightPSRIO.initialize([path])
LightPSRIO.run_file(L, script_path)
finalize(L)
