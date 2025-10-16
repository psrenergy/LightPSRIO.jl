local generic = Generic();

-- local configurations = { "2000f_36t_100s_25o_6p", "2000f_36t_100s_100o_6p", "2000f_36t_100s_200o_6p" };
local configurations = { "13h_12t_2s_1o_6p", "24h_24t_2s_1o_6p", "81h_60t_2s_1o_6p" };
-- local models = { "parp", "auto_arima" };
local models = { "parp" };
local strategies = { "yearly_wise", "stage_wise_k1", "stage_wise_k3" };

local colors = {
    "#2caffe",
    "#544fc5",
    "#00e272",
    "#fe6a35",
    "#6b8abc",
    "#d568fb",
    "#2ee0ca",
    "#fa4b42",
    "#feb56a",
    "#91e8e1"
};

local function add_percentile(chart, data, color)
    local avg = data:aggregate("scenario", BY_AVERAGE()):add_suffix(" (avg)");
    chart:add("line", avg, { color = color });

    local p90 = data:aggregate("scenario", BY_PERCENTILE(90)):add_suffix(" (p10-p90)");
    local p10 = data:aggregate("scenario", BY_PERCENTILE(10)):add_suffix(" (p10-p90)");
    chart:add("area_range", p10, p90, { color = color, fillOpacity = 0.4, visible = false });
end

local function add_percentile_to_tab(tab, title, filename, agent)
    for _, model in ipairs(models) do
        local chart = Chart(title .. " - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/" .. filename);
                data = data:select_agents({ agent });
                data = data:rename_agents({ label });
                add_percentile(chart, data, colors[i]);
                i = i + 1;
            end
        end
        tab:push(chart);
    end
end

local function tab_cost_analysis()
    local tab = Tab("Cost Analysis");

    for _, model in ipairs(models) do
        local chart = Chart("Total Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy

                local data = generic:load(label .. "/results/costs_by_category");
                data = data:select_agents({ 1 });
                data = data:rename_agents({ label });
                add_percentile(chart, data, colors[i]);
                i = i + 1;
            end
        end
        tab:push(chart);
    end

    local chart = Chart("Immediate Cost");
    for _, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/results/costs_by_category");
                data = data:select_agents({ 2 });
                data = data:rename_agents({ label });
                data = data:aggregate("scenario", BY_SUM());
                data = data:aggregate("stage", BY_SUM());
                chart:add("column", data);
            end
        end
    end
    tab:push(chart);

    for _, model in ipairs(models) do
        local chart = Chart("Immediate Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/results/costs_by_category");
                data = data:select_agents({ 2 });
                data = data:rename_agents({ label });
                add_percentile(chart, data, colors[i]);
                i = i + 1;
            end
        end
        tab:push(chart);
    end

    for _, model in ipairs(models) do
        local chart = Chart("Marginal Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/results/load_marginal_cost");
                data = data:aggregate_agents(BY_AVERAGE(), label);
                add_percentile(chart, data, colors[i]);
                i = i + 1;
            end
        end
        tab:push(chart);
    end

    for _, model in ipairs(models) do
        local chart = Chart("Deficit - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/results/deficit");
                data = data:aggregate_agents(BY_AVERAGE(), label);
                add_percentile(chart, data, colors[i]);
                i = i + 1;
            end
        end
        tab:push(chart);
    end

    return tab;
end

local function tab_demand_analysis()
    local tab = Tab("Demand Analysis");

    for _, configuration in ipairs(configurations) do
        for _, model in ipairs(models) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local chart = Chart("Balance - " .. label);

                local data = generic:load(label .. "/results/demand");
                data = data:aggregate_agents(BY_SUM(), "Total Demand");
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("line", data, { color = "orange" });

                local data = generic:load(label .. "/results/hydro_generation");
                data = data:aggregate_agents(BY_SUM(), "Total Hydro")
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("area_stacking", data, { color = "blue" });

                local data = generic:load(label .. "/results/thermal_generation");
                data = data:aggregate_agents(BY_SUM(), "Total Thermal");
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("area_stacking", data, { color = "red" });

                local data = generic:load(label .. "/results/deficit");
                data = data:aggregate_agents(BY_SUM(), "Total Deficit");
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("area_stacking", data, { color = "black" });

                tab:push(chart);
            end
        end
    end

    return tab;
end

local function tab_hydro_analysis(agent)
    local tab = Tab("Hydro Analysis (agent " .. agent .. ")");

    local chart = Chart("Real Historical Data");

    local data =
        generic:load(configurations[1] .. "/" .. models[1] .. "_" .. strategies[1] .. "/inflow_real_historical");
    data = data:select_agents({ agent }):rename_agents({ "min-max" });
    local min = data:year_profile(BY_MIN());
    local max = data:year_profile(BY_MAX());
        chart:add("area_range", min:replicate("stage", 10), max:replicate("stage", 10), { fillOpacity = 0.4 });

    for _, model in ipairs(models) do

        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/inflow_real_historical");
                data = data:select_agents({ agent });
                data = data:rename_agents({ label });
                chart:add("line", data);
            end
        end
    end
    tab:push(chart);

    local chart = Chart("Fake Historical Data");
    for _, model in ipairs(models) do

        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/inflow_fake_historical");
                data = data:select_agents({ agent });
                data = data:rename_agents({ label });
                chart:add("line", data);
            end
        end
    end
    tab:push(chart);

    for _, model in ipairs(models) do
        local chart = Chart("Inflow - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                local label = configuration .. "/" .. model .. "_" .. strategy;

                local data = generic:load(label .. "/inflow_scenarios_train");
                data = data:select_agents({ agent });
                data = data:rename_agents({ label .. " - train (avg)" });
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("line", data, { color = colors[i] });

                local data = generic:load(label .. "/inflow_scenarios_simulate");
                data = data:select_agents({ agent });
                data = data:rename_agents({ label .. " - simulate (avg)" });
                data = data:aggregate("scenario", BY_AVERAGE());
                chart:add("line", data, { color = colors[i] });

                local data = generic:load(label .. "/results/hydro_inflow");
                data = data:select_agents({ agent });
                data = data:rename_agents({ label .. " - result" });
                add_percentile(chart, data, colors[i]);

                i = i + 1;
            end
        end

        tab:push(chart);
    end

    -- add_percentile_to_tab(tab, "Hydro Generation", "results/hydro_generation", agent);
    -- add_percentile_to_tab(tab, "Final Volume", "results/hydro_final_volume", agent);

    return tab;
end

local function tab_thermal_analysis(agent)
    local tab = Tab("Thermal Analysis (agent " .. agent .. ")");

    add_percentile_to_tab(tab, "Thermal Generation", "results/thermal_generation", agent);

    return tab;
end

local dashboard = Dashboard("PSR");
-- dashboard:push(tab_demand_analysis());
-- dashboard:push(tab_cost_analysis());
for agent = 1, 1 do
    dashboard:push(tab_hydro_analysis(agent));
    -- dashboard:push(tab_thermal_analysis(agent));
end
dashboard:save("dashboard");
