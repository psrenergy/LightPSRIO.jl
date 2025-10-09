local generic = Generic();

-- local cases = { "parp", "auto_arima", "seasonal_naive" };
local cases = { "parp", "seasonal_naive" };

local methodologies = { "yearly_wise", "stage_wise_k1", "stage_wise_k3" };

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

--     local markdown = Markdown();
--     markdown:add("# Demand Analysis");
--     tab:push(markdown);

--     for index, case in ipairs(cases) do
--         local chart = Chart("Balance - " .. case_name);

--         local data = generic:load("results/demand");
--         data = data:aggregate_agents(BY_SUM(), "Total Demand");
--         data = data:aggregate("scenario", BY_AVERAGE());
--         chart:add("line", data);

--         local data = generic:load("results/hydro_generation")
--         data = data:aggregate_agents(BY_SUM(), "Total Hydro")
--         data = data:aggregate("scenario", BY_AVERAGE());
--         chart:add("area_stacking", data, { color = "blue" });

--         local data = generic:load("results/thermal_generation");
--         data = data:aggregate_agents(BY_SUM(), "Total Thermal");
--         data = data:aggregate("scenario", BY_AVERAGE());
--         chart:add("area_stacking", data, { color = "red" });

--         local data = generic:load("results/deficit");
--         data = data:aggregate_agents(BY_SUM(), "Total Deficit");
--         data = data:aggregate("scenario", BY_AVERAGE());
--         chart:add("area_stacking", data, { color = "black" });

--         tab:push(chart);
--     end

--     return tab;
-- end

local function tab_hydro_analysis(agent)
    local tab = Tab("Hydro Analysis (agent " .. agent .. ")");
    tab:push("# Inflow Analysis");

    for _, case in ipairs(cases) do
        local chart = Chart(case);

        for _, methodology in ipairs(methodologies) do
            print("PROCESSING: " .. case);
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "inflow_scenarios_train");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ methodology .. " - train" });
            chart:add("line", data);

            local data = generic:load(prefix .. "inflow_scenarios_simulation");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ methodology .. " - simulation" });
            chart:add("line", data);

            local data = generic:load(prefix .. "results/hydro_inflow");
            data = data:select_agents({ agent });
            data = data:aggregate("scenario", BY_AVERAGE());
            data = data:rename_agents({ methodology .. " - result" });
            chart:add("line", data);

            local data = generic:load(prefix .. "results/hydro_inflow");
            data = data:select_agents({ agent });
            max = data:aggregate("scenario", BY_MAX());
            min = data:aggregate("scenario", BY_MIN());
            chart:add("area_range", min, max);
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

local dashboard = Dashboard("PSR");
for agent = 1, 4 do

    -- dashboard:push(tab_home());
    -- dashboard:push(tab_cost_analysis());
    -- dashboard:push(tab_demand_analysis());
    dashboard:push(tab_hydro_analysis(agent));
    -- dashboard:push(tab_thermal_analysis());
    -- dashboard:push(tab_renewable_analysis());

end

dashboard:save("dashboard1");
