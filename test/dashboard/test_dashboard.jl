module TestDashboard

using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Dashboard" begin
    setup_tests(
        create_quiver2("input_year"; constant = 2.0, frequency = "year", unit = "GWh", dimensions = ["year"], dimension_size = [10]),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input_year");

local tab = Tab("Tab 1");

local chart = Chart("Line");
chart:add("line", input1);
tab:push(chart);

local chart = Chart("Column Stacking");
chart:set_y_axis_options({ stackLabels = { enabled = true } });
chart:add("column_stacking", input1);
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
