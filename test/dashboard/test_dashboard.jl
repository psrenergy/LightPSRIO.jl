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

-- Line chart with data
chart1 = Chart("CPU Usage Over Time", "line");
chart1:add_data("00:00", 45.2);
chart1:add_data("01:00", 52.1);  
chart1:add_data("02:00", 38.7);
chart1:add_data("03:00", 61.3);
chart1:add_data("04:00", 42.9);
tab1:push(chart1);

-- Bar chart with data  
chart2 = Chart("Memory Usage by Process", "bar");
chart2:add_data("Process A", 256);
chart2:add_data("Process B", 512);
chart2:add_data("Process C", 128); 
chart2:add_data("Process D", 1024);
tab1:push(chart2);

dashboard:push(tab1);

-- Create second tab with different charts
tab2 = Tab("System Analysis");

-- Pie chart
chart3 = Chart("Disk Space Distribution", "pie");
chart3:add_data("OS", 25);
chart3:add_data("Applications", 35);
chart3:add_data("Documents", 15);
chart3:add_data("Media", 20);
chart3:add_data("Other", 5);
tab2:push(chart3);

-- Doughnut chart
chart4 = Chart("Network Traffic", "doughnut");
chart4:add_data("HTTP", 60);
chart4:add_data("HTTPS", 35);
chart4:add_data("FTP", 5);
tab2:push(chart4);

dashboard:push(tab2);

-- Create third tab with empty chart to test edge cases
tab3 = Tab("Empty Data");  
chart5 = Chart("No Data Chart", "line");
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