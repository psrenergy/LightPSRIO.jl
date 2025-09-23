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
print("Creating dashboard...")
dashboard = Dashboard();

-- Create first tab with charts
tab1 = Tab("Performance Metrics");

-- Line chart with Chart.js
chart1 = ChartJS("CPU Usage Over Time", "line");
tab1:push(chart1);

-- Bar chart with Highcharts
chart2 = Highcharts("Memory Usage by Process", "bar");
tab1:push(chart2);

dashboard:push(tab1);

-- Create second tab with different charts
tab2 = Tab("System Analysis");

-- Pie chart with Chart.js
chart3 = ChartJS("Disk Space Distribution", "pie");
tab2:push(chart3);

-- Doughnut chart with Highcharts
chart4 = Highcharts("Network Traffic", "doughnut");
tab2:push(chart4);

dashboard:push(tab2);

-- Create third tab with empty chart to test edge cases
tab3 = Tab("Empty Data");  
chart5 = ChartJS("No Data Chart", "line");
tab3:push(chart5);
dashboard:push(tab3);

print("Saving dashboard as HTML...")
-- Save the dashboard as HTML
dashboard:save("demo_dashboard");

print("Dashboard saved successfully!");
    """,
    )

    finalize(L)

    return nothing
end

end
