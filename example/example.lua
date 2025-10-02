local generic = Generic();

local function tab_generation()
    local tab = Tab("Balance");

    local demand = generic:load("demand"):aggregate_agents(BY_SUM(), "Total Demand"):aggregate("scenario", BY_AVERAGE());

    local hydro_generation = generic:load("hydro_generation"):aggregate_agents(BY_SUM(), "Total Hydro"):aggregate("scenario", BY_AVERAGE());

    local thermal_generation = generic:load("thermal_generation"):aggregate_agents(BY_SUM(), "Total Thermal"):aggregate("scenario", BY_AVERAGE());

    local deficit = generic:load("deficit"):aggregate_agents(BY_SUM(), "Total Deficit"):aggregate("scenario", BY_AVERAGE());

    local chart = Chart("Generation");
    chart:add("line", demand);
    chart:add("area_stacking", hydro_generation);
    chart:add("area_stacking", thermal_generation);
    chart:add("area_stacking", deficit, { color = "black" });
    tab:push(chart);

    return tab;
end

local function tab_inflow()
    local tab = Tab("Inflow");

    local inflow = generic:load("hydro_inflow"):aggregate("scenario", BY_AVERAGE());

    local chart = Chart("Inflow");
    chart:add("line", inflow);
    tab:push(chart);

    return tab;
end

local dashboard = Dashboard();
dashboard:push(tab_generation());
dashboard:push(tab_inflow());
dashboard:save("dashboard");
