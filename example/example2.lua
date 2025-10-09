local generic = Generic();

local methodologies = { "yearly_wise", "stage_wise_k1", "stage_wise_k3" };

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

local function tab_cost_analysis(cases)
    local tab = Tab("Cost Analysis");

    for _, case in ipairs(cases) do
        local chart = Chart("Total Cost - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/costs_by_category");
            data = data:select_agents({ 1 });
            data = data:rename_agents({ methodology });
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    for _, case in ipairs(cases) do
        local chart = Chart("Immediate Cost - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/costs_by_category");
            data = data:select_agents({ 2 });
            data = data:rename_agents({ methodology });
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    for _, case in ipairs(cases) do
        local chart = Chart("Marginal Cost - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/load_marginal_cost");
            data = data:aggregate_agents(BY_AVERAGE(), "methodology");
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    for _, case in ipairs(cases) do
        local chart = Chart("Deficit - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/deficit");
            data = data:aggregate_agents(BY_AVERAGE(), "methodology");
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    return tab;
end

local function tab_demand_analysis(cases)
    local tab = Tab("Demand Analysis");

    for _, case in ipairs(cases) do
        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology;

            local chart = Chart("Balance - " .. prefix);

            local data = generic:load(prefix .. "/results/demand");
            data = data:aggregate_agents(BY_SUM(), "Total Demand");
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("line", data, { color = "orange" });

            local data = generic:load(prefix .. "/results/hydro_generation");
            data = data:aggregate_agents(BY_SUM(), "Total Hydro")
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("area_stacking", data, { color = "blue" });

            local data = generic:load(prefix .. "/results/thermal_generation");
            data = data:aggregate_agents(BY_SUM(), "Total Thermal");
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("area_stacking", data, { color = "red" });

            local data = generic:load(prefix .. "/results/deficit");
            data = data:aggregate_agents(BY_SUM(), "Total Deficit");
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("area_stacking", data, { color = "black" });

            tab:push(chart);
        end
    end

    return tab;
end

local function tab_hydro_analysis(cases, agent)
    local tab = Tab("Hydro Analysis (agent " .. agent .. ")");

    for _, case in ipairs(cases) do
        local chart = Chart("Inflow - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "inflow_scenarios_train");
            data = data:select_agents({ agent });
            data = data:rename_agents({ methodology .. " - train (avg)" });
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("line", data, { color = colors[j] });

            local data = generic:load(prefix .. "inflow_scenarios_simulation");
            data = data:select_agents({ agent });
            data = data:rename_agents({ methodology .. " - simulation (avg)" });
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("line", data, { color = colors[j] });

            local data = generic:load(prefix .. "results/hydro_inflow");
            data = data:select_agents({ agent });
            data = data:rename_agents({ methodology .. " - result" });
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    for _, case in ipairs(cases) do
        local chart = Chart("Final Volume - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/hydro_final_volume");
            data = data:select_agents({ agent });
            data = data:rename_agents({ methodology });
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    return tab;
end

local function tab_thermal_analysis(cases, agent)
    local tab = Tab("Thermal Analysis (agent " .. agent .. ")");

    for _, case in ipairs(cases) do
        local chart = Chart("Deficit - " .. case);

        for j, methodology in ipairs(methodologies) do
            local prefix = case .. "_" .. methodology .. "/";

            local data = generic:load(prefix .. "results/thermal_generation");
            data = data:select_agents({ agent });
            data = data:rename_agents({ methodology });
            add_percentile(chart, data, colors[j]);
        end

        tab:push(chart);
    end

    return tab;
end

local configurations = { "2000f_36t_100s_25o_1p", "2000f_36t_100s_25o_6p" };

for _, configuration in ipairs(configurations) do
    local cases = { configuration .. "/parp", configuration .. "/auto_arima" };

    local dashboard = Dashboard(configuration);

    dashboard:push(tab_demand_analysis(cases));
    dashboard:push(tab_cost_analysis(cases));

    for agent = 1, 1 do
        dashboard:push(tab_hydro_analysis(cases, agent));
        dashboard:push(tab_thermal_analysis(cases, agent));
    end

    dashboard:save(configuration);
end

