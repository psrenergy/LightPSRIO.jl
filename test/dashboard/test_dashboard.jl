module TestDashboard

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Dashboard" begin
    setup_tests(
        create_quiver2("input_year"; constant = 2.0, frequency = "year", unit = "GWh", dimensions = ["year"], dimension_size = [10])
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input_year");

print(input1)
    
local chart = Chart("");
chart:add("line", input1);

local tab = Tab("Tab 1");
tab:push(chart);

local dashboard = Dashboard("PSR");
dashboard:push(tab);
dashboard:save("dashboard");
""",
        )

        return nothing
    end

    return nothing
end

end
