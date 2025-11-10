using LightPSRIO

path = raw"C:\Development\Papers\AStudyOnCuttingPlaneStrategiesAppliedToSDDP.jl\data"
script_path = raw"C:\Development\PSRIO\LightPSRIO.jl\example\cutting_plane.lua"

L = LightPSRIO.initialize([path])
LightPSRIO.run_file(L, script_path)
finalize(L)
