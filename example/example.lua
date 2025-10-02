local generic = Generic();

local hydro_generation = generic
    :load("hydro_generation")
    :aggregate_agents(BY_SUM(), "Total Hydro")
    :aggregate("scenario", BY_AVERAGE());

local thermal_generation = generic
    :load("thermal_generation")
    :aggregate_agents(BY_SUM(), "Total Thermal")
    :aggregate("scenario", BY_AVERAGE());

local deficit = generic
    :load("deficit")
    :aggregate_agents(BY_SUM(), "Total Deficit")
    :aggregate("scenario", BY_AVERAGE());

local tab = Tab("Performance Metrics");

local chart = Chart("Generation");
chart:add_line(hydro_generation);
chart:add_line(thermal_generation);
chart:add_line(deficit);
tab:push(chart);

local dashboard = Dashboard();
dashboard:push(tab);
dashboard:save("demo_dashboard");
