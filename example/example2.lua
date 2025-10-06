local cases = { yearly_wise = Generic(1), stage_wise_k1 = Generic(2), stage_wise_k3 = Generic(3) };

local colors = { "#ff0029", "#377eb8", "#66a61e", "#984ea3" };

-- local function tab_home()
--     local tab = Tab("Home");
--     return tab;
-- end
-- local function tab_cost_analysis()
--     local tab = Tab("Cost Analysis");
--     return tab;
-- end
-- local function tab_demand_analysis()
--     local tab = Tab("Demand Analysis");
--     local demand = generic:load("demand"):aggregate_agents(BY_SUM(), "Total Demand"):aggregate("scenario", BY_AVERAGE());
--     local hydro_generation = generic:load("hydro_generation"):aggregate_agents(BY_SUM(), "Total Hydro"):aggregate("scenario", BY_AVERAGE());
--     local thermal_generation = generic:load("thermal_generation"):aggregate_agents(BY_SUM(), "Total Thermal"):aggregate("scenario", BY_AVERAGE());
--     local deficit = generic:load("deficit"):aggregate_agents(BY_SUM(), "Total Deficit"):aggregate("scenario", BY_AVERAGE());
--     local chart = Chart("Generation");
--     chart:add("line", demand);
--     chart:add("area_stacking", deficit, { color = "black" });
--     chart:add("area_stacking", thermal_generation, { color = "red" });
--     chart:add("area_stacking", hydro_generation, { color = "blue" });
--     tab:push(chart);
--     return tab;
-- end
local function tab_hydro_analysis()
    local tab = Tab("Hydro Analysis");

    for agent = 1, 4 do
        local chart = Chart("Inflow Scenarios - Agent " .. agent);

        for case_name, generic in pairs(cases) do
            local inflow_scenarios_train = generic:load("inflow_scenarios_train"):select_agents({ agent }):aggregate(
                                               "scenario", BY_AVERAGE()
                                           ):add_suffix(" (train - case " .. case_name .. ")");
            chart:add("line", inflow_scenarios_train);

            local inflow_scenarios_simulation = generic:load("inflow_scenarios_simulation"):select_agents({ agent })
                                                    :aggregate(
                                                        "scenario", BY_AVERAGE()
                                                    ):add_suffix(" (simulation - case " .. case_name .. ")");
            chart:add("line", inflow_scenarios_simulation);
        end

        tab:push(chart);
    end

    return tab;
end

-- local function tab_thermal_analysis()
--     local tab = Tab("Thermal Analysis");
--     return tab;
-- end

-- local function tab_renewable_analysis()
--     local tab = Tab("Renewable Analysis");
--     return tab;
-- end

local dashboard = Dashboard();
-- dashboard:push(tab_home());
-- dashboard:push(tab_cost_analysis());
-- dashboard:push(tab_demand_analysis());
dashboard:push(tab_hydro_analysis());
-- dashboard:push(tab_thermal_analysis());
-- dashboard:push(tab_renewable_analysis());
dashboard:save("dashboard");
