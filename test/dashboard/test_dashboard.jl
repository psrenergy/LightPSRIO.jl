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

print("Creating dashboard...")
dashboard = Dashboard();

-- Create first tab with charts
tab = Tab("Performance Metrics");

-- Line chart with data
chart = Chart("CPU Usage Over Time", "line");
tab:push(chart);

-- Bar chart with data  
chart = Chart("Memory Usage by Process", "bar");
tab:push(chart);

dashboard:push(tab);

-- Create second tab with different charts
tab = Tab("System Analysis");

-- Pie chart
chart = Chart("Disk Space Distribution", "pie");
tab:push(chart);

-- Doughnut chart
chart = Chart("Network Traffic", "doughnut");
tab:push(chart);

dashboard:push(tab);

-- Create third tab with empty chart to test edge cases
tab = Tab("Empty Data");  
chart = Chart("No Data Chart", "line");
tab:push(chart);
dashboard:push(tab);

dashboard:save("demo_dashboard");

print("Dashboard saved successfully!");
    """,
    )

    finalize(L)

    return nothing
end

end