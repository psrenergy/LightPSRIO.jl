using LightPSRIO

case_path = raw"C:\Users\rsampaio\Downloads\deck_Iara_17"
script_path = raw"C:\Development\PSRIO\LightPSRIO.jl\example\example1.lua"

L = LightPSRIO.initialize([case_path])
LightPSRIO.run_file(L, script_path)
finalize(L)
