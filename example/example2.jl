using LightPSRIO

case2 = raw"C:\Development\PSRIO\LightPSRIO.jl\data\seasonal_naive_stage_wise_k1"
case3 = raw"C:\Development\PSRIO\LightPSRIO.jl\data\seasonal_naive_stage_wise_k3"
script_path = raw"C:\Development\PSRIO\LightPSRIO.jl\example\example2.lua"

L = LightPSRIO.initialize(
    [
        case2,
        case3
    ]
)
LightPSRIO.run_file(L, script_path)
finalize(L)
