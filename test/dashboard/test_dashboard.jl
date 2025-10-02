module TestDashboard

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Dashboard" begin
    initialize_tests()
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

dashboard = Dashboard();

-- Create first tab with charts
tab = Tab("Performance Metrics");

-- Line chart with data
chart = Chart("CPU Usage Over Time");
chart:add_line(input1);
tab:push(chart);

-- Bar chart with data  
chart = Chart("Memory Usage by Process");
tab:push(chart);

dashboard:push(tab);

-- Create second tab with different charts
tab = Tab("System Analysis");

-- Pie chart
chart = Chart("Disk Space Distribution");
tab:push(chart);

-- Doughnut chart
chart = Chart("Network Traffic");
tab:push(chart);

dashboard:push(tab);

-- Create third tab with empty chart to test edge cases
tab = Tab("Empty Data");  
chart = Chart("No Data Chart");
tab:push(chart);
dashboard:push(tab);

dashboard:save("demo_dashboard");
    """,
    )

    finalize(L)

    return nothing
end

end
