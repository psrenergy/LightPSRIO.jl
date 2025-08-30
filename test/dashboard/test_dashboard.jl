module TestDashboard

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../util.jl")

@testset "Dashboard" begin
    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
dashboard = Dashboard();
chart1 = Chart();
chart2 = Chart();
chart3 = Chart();

tab1 = Tab("Tab 1");
tab1:push(chart1);
tab1:push(chart2);

tab2 = Tab("Tab 2");
tab2:push(chart3);

dashboard:push(tab1);
dashboard:push(tab2);
dashboard:save("dashboard");
    """,
    )

    finalize(L)

    return nothing
end

end
