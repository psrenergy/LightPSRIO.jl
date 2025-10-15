using LightPSRIO

# path = raw"C:\Development\HydroThermalDispatch\HydroThermalDispatch.jl2\test\brazil_4_reservoirs\deterministic"
path = raw"C:\Development\HydroThermalDispatch\HydroThermalDispatch.jl2\test\brazil_4_reservoirs\stochastic_ar_1_full_tree"
script_path = raw"C:\Development\HydroThermalDispatch\HydroThermalDispatch.jl2\database\scripts\dashboard.lua"

L = LightPSRIO.initialize([path])
LightPSRIO.run_file(L, script_path)
finalize(L)
