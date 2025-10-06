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

local function tab_demand_analysis()
    local tab = Tab("Demand Analysis");

    local markdown = Markdown();
    markdown:add("# Demand Analysis");
    tab:push(markdown);

    for case_name, generic in pairs(cases) do
        local chart = Chart("Balance - " .. case_name);

        local data = generic:load("results/demand");
        data = data:aggregate_agents(BY_SUM(), "Total Demand");
        data = data:aggregate("scenario", BY_AVERAGE());
        chart:add("line", data);

        local data = generic:load("results/hydro_generation")
        data = data:aggregate_agents(BY_SUM(), "Total Hydro")
        data = data:aggregate("scenario", BY_AVERAGE());
        chart:add("area_stacking", data, { color = "blue" });

        local data = generic:load("results/thermal_generation");
        data = data:aggregate_agents(BY_SUM(), "Total Thermal");
        data = data:aggregate("scenario", BY_AVERAGE());
        chart:add("area_stacking", data, { color = "red" });

        local data = generic:load("results/deficit");
        data = data:aggregate_agents(BY_SUM(), "Total Deficit");
        data = data:aggregate("scenario", BY_AVERAGE());
        chart:add("area_stacking", data, { color = "black" });

        tab:push(chart);
    end

    return tab;
end

local function tab_hydro_analysis()
    local tab = Tab("Hydro Analysis");

    for agent = 1, 4 do
        local chart = Chart("Inflow - Agent " .. agent);

        for case_name, generic in pairs(cases) do
            local data = generic:load("inflow_scenarios_train");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ case_name .. " - train" });
            chart:add("line", data);

            local data = generic:load("inflow_scenarios_simulation");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ case_name .. " - simulation" });
            chart:add("line", data);

            local data = generic:load("results/hydro_inflow");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ case_name .. " - result" });
            chart:add("line", data);
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
dashboard:push(tab_demand_analysis());
dashboard:push(tab_hydro_analysis());
-- dashboard:push(tab_thermal_analysis());
-- dashboard:push(tab_renewable_analysis());
dashboard:save("dashboard");
