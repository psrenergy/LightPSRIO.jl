using LightPSRIO

path = raw"C:\Development\PSRIO\LightPSRIO.jl\data"
# case = "seasonal_naive"
# case = "auto_arima"
case = "parp"
case1 = joinpath(path, "$(case)_yearly_wise")
case2 = joinpath(path, "$(case)_stage_wise_k1")
case3 = joinpath(path, "$(case)_stage_wise_k3")
script_path = raw"C:\Development\PSRIO\LightPSRIO.jl\example\example2.lua"

L = LightPSRIO.initialize(
    [
        case1,
        case2,
        case3
    ]
)
LightPSRIO.run_file(L, script_path)
finalize(L)
