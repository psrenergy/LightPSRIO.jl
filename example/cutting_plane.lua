local generic = Generic();

local configurations = {
    "60t_100s_25o",
};

local strategies = {
    "single-cut",
    "multi-cut",
    "multi-cut-with-sampling",
};

local colours = {
    "#ff0029", "#377eb8", "#66a61e", "#984ea3",
    "#00d2d5", "#ff7f00", "#af8d00", "#7f80cd",
    "#b3e900", "#c42e60", "#a65628", "#f781bf",
    "#8dd3c7", "#bebada", "#fb8072", "#80b1d3",
    "#fdb462", "#fccde5", "#bc80bd", "#ffed6f",
    "#c4eaff", "#cf8c00", "#1b9e77", "#d95f02",
    "#e7298a", "#e6ab02", "#a6761d", "#0097ff",
    "#00d067", "#000000", "#252525", "#525252",
    "#737373", "#969696", "#bdbdbd", "#f43600",
    "#4ba93b", "#5779bb", "#927acc", "#97ee3f",
    "#bf3947", "#9f5b00", "#f48758", "#8caed6",
    "#f2b94f", "#eff26e", "#e43872", "#d9b100",
    "#9d7a00", "#698cff", "#d9d9d9", "#00d27e",
    "#d06800", "#009f82", "#c49200", "#cbe8ff",
    "#fecddf", "#c27eb6", "#8cd2ce", "#c4b8d9",
    "#f883b0", "#a49100", "#f48800", "#27d0df",
    "#a04a9b"
};

local function add_percentile(chart, data, color)
    local avg = data:aggregate("scenario", BY_AVERAGE()):add_suffix(" (avg)");
    chart:add("line", avg, { color = color });

    local p90 = data:aggregate("scenario", BY_PERCENTILE(90)):add_suffix(" (p10-p90)");
    local p10 = data:aggregate("scenario", BY_PERCENTILE(10)):add_suffix(" (p10-p90)");
    chart:add("area_range", p10, p90, { color = color, fillOpacity = 0.4, visible = false });
end

local function add_percentile_to_tab(tab, title, filename, agent)
    local chart = Chart(title);

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/" .. filename);
            data = data:select_agents({ agent });
            data = data:rename_agents({ label });
            add_percentile(chart, data, colours[i]);
            i = i + 1;
        end
    end
    tab:push(chart);
end

local function tab_cost_analysis()
    local tab = Tab("Cost Analysis");

    local chart = Chart("Total Cost");

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/results/costs_by_category");
            data = data:select_agents({ 1 });
            data = data:rename_agents({ label });
            add_percentile(chart, data, colours[i]);
            i = i + 1;
        end
    end
    tab:push(chart);

    local chart = Chart("Immediate Cost");
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/results/costs_by_category");
            data = data:select_agents({ 2 });
            data = data:rename_agents({ label });
            data = data:aggregate("scenario", BY_SUM());
            data = data:aggregate("stage", BY_SUM());
            chart:add("column", data, { color = colours[i] });
        end
    end
    tab:push(chart);

    local chart = Chart("Immediate Cost");

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/results/costs_by_category");
            data = data:select_agents({ 2 });
            data = data:rename_agents({ label });
            add_percentile(chart, data, colours[i]);
            i = i + 1;
        end
    end
    tab:push(chart);

    local chart = Chart("Marginal Cost");

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/results/load_marginal_cost");
            data = data:aggregate_agents(BY_AVERAGE(), label);
            add_percentile(chart, data, colours[i]);
            i = i + 1;
        end
    end
    tab:push(chart);

    local chart = Chart("Deficit");

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/results/deficit");
            data = data:aggregate_agents(BY_AVERAGE(), label);
            add_percentile(chart, data, colours[i]);
            i = i + 1;
        end
    end
    tab:push(chart);

    return tab;
end

local function tab_demand_analysis()
    local tab = Tab("Demand Analysis");

    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

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

    return tab;
end

local function get_years(filename)
    local years = 0;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local data = generic:load(configuration .. "/" .. strategy .. "/" .. filename);
            years = math.max(years, data:get_years());
        end
    end
    return years;
end

local function tab_hydro_analysis(agent)
    local tab = Tab("Hydro Analysis (agent " .. agent .. ")");

    local real = generic
        :load(configurations[1] .. "/" .. strategies[1] .. "/inflow_real_historical")
        :select_agents({ agent })
        :rename_agents({ "real historical" });

    local real_min = real:year_profile(BY_MIN()):add_suffix("(min-max)");
    local real_max = real:year_profile(BY_MAX()):add_suffix("(min-max)");

    local chart = Chart("Real Historical Data");
    chart:add(
        "area_range",
        real_min:replicate("stage", 82),
        real_max:replicate("stage", 82),
        { fillOpacity = 0.4, color = "gray" }
    );
    chart:add("line", real);
    tab:push(chart);

    local fake_years = get_years("inflow_fake_historical");

    local chart = Chart("Fake Historical Data");
    for _, configuration in ipairs(configurations) do
        local data = generic:load(configuration .. "/" .. strategies[1] .. "/inflow_fake_historical");
        data = data:select_agents({ agent });
        data = data:rename_agents({ configuration });
        chart:add("line", data);
    end
    tab:push(chart);

    local chart = Chart("Inflow");

    local i = 1;
    for _, configuration in ipairs(configurations) do
        for _, strategy in ipairs(strategies) do
            local label = configuration .. "/" .. strategy;

            local data = generic:load(label .. "/inflow_scenarios_train");
            data = data:select_agents({ agent });
            data = data:rename_agents({ label .. " - train (avg)" });
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("line", data, { color = colours[i] });

            local data = generic:load(label .. "/inflow_scenarios_simulate");
            data = data:select_agents({ agent });
            data = data:rename_agents({ label .. " - simulate (avg)" });
            data = data:aggregate("scenario", BY_AVERAGE());
            chart:add("line", data, { color = colours[i] });

            local data = generic:load(label .. "/results/hydro_inflow");
            data = data:select_agents({ agent });
            data = data:rename_agents({ label .. " - result" });
            add_percentile(chart, data, colours[i]);

            i = i + 1;
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
dashboard:push(tab_demand_analysis());
dashboard:push(tab_cost_analysis());
for agent = 1, 1 do
    dashboard:push(tab_hydro_analysis(agent));
    dashboard:push(tab_thermal_analysis(agent));
end
dashboard:save("dashboard");
