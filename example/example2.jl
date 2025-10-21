using LightPSRIO

# path = raw"C:\Development\PSRIO\LightPSRIO.jl\data"
path = raw"C:\Development\Papers\GeneralTimeSeriesApproximationInSDDP.jl\data"
# path = raw"C:\Development\Papers\GeneralTimeSeriesApproximationInSDDP.jl\results"
script_path = raw"C:\Development\PSRIO\LightPSRIO.jl\example\example2.lua"

L = LightPSRIO.initialize([path])
LightPSRIO.run_file(L, script_path)
finalize(L)
