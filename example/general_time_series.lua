local generic = Generic();

local configurations = {
    -- -- "400h_24t_50s_50o_6p_20i",
    -- -- "400h_24t_50s_50o_1p_20i",
    -- -- "800h_60t_100s_100o_1p_20i",
    -- "800h_60t_100s_100o_6p_20i",
    -- -- "400h_60t_50s_50o_6p_20i",
    -- -- "1600h_60t_200s_200o_6p_20i",
    -- "1600h_60t_200s_200o_6p_100i",
    -- -- "24h_12t_5s_5o_1p_20i",
    -- "2000h_60t_500s_500o_6p_100i",
    -- -- "24h_12t_5s_5o_1p_20i",
    -- -- "10h_2t_5s_5o_1p_10i",
    -- "2000h_60t_400s_400o_6p_100i",
    -- "1000h_60t_100s_100o_6p_200i",
    -- "2000h_60t_200s_200o_6p_200i",
    -- "1000h_60t_100s_100o_6p_200i",
    -- "1600h_60t_200s_200o_6p_20i",
    -- "1600h_60t_200s_200o_6p_100i",
    -- "2000h_60t_200s_200o_6p_200i",
    -- "2000h_60t_300s_300o_6p_200i",
    -- "2000h_60t_400s_400o_6p_100i",
    -- "2000h_60t_500s_500o_6p_100i",
    -- "800h_60t_100s_100o_6p_20i",
    "2000h_36t_100s_100o_6p_25i",
    "2000h_36t_200s_200o_6p_25i",
    -- "2000h_36t_100s_100o_6p_50i",
};

local models = {
    "parp",
    "heavy_tailed",
    "long_memory",
    "msar",
};

local strategies = {
    "yearly_wise",
    "stage_wise_k1",
    "stage_wise_k2",
    "stage_wise_k3",
    "stage_wise_k4",
};

local versions = {
    -- "0.1.6",
    "0.1.7",
}

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

local function get_label(configuration, model, strategy, version)
    return configuration .. "/" .. model .. "_" .. strategy .. "_" .. version;
end

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
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/" .. filename);
                    data = data:select_agents({ agent });
                    data = data:rename_agents({ label });
                    add_percentile(chart, data, colours[i]);
                    i = i + 1;
                end
            end
        end
        tab:push(chart);
    end
end

local function get_years(filename)
    local years = 0;
    for _, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/" .. filename);
                    years = math.max(years, data:get_years());
                end
            end
        end
    end
    return years;
end

local function tab_cost_analysis()
    local tab = Tab("Cost Analysis");

    for _, model in ipairs(models) do
        local chart = Chart("Total Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/costs_by_category");
                    data = data:select_agents({ 1 });
                    data = data:rename_agents({ label });
                    add_percentile(chart, data, colours[i]);
                    i = i + 1;
                end
            end
        end
        tab:push(chart);
    end

    local chart = Chart("Immediate Cost");
    for i, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/costs_by_category");
                    data = data:select_agents({ 2 });
                    data = data:rename_agents({ label });
                    data = data:aggregate("scenario", BY_AVERAGE());
                    data = data:aggregate("stage", BY_SUM());
                    chart:add("column", data, { color = colours[i] });
                end
            end
        end
    end
    tab:push(chart);

    -- local markdown = Markdown()
    -- markdown:add(
    -- "| Model                       | Violation Type     | Severity        | Best For                        |");
    -- markdown:add(
    -- "|:----------------------------|:-------------------|:---------------:|:--------------------------------|");
    -- markdown:add(
    -- "| `regime_switching`          | State dependence   | Severe          | Persistent droughts/wet periods |");
    -- markdown:add(
    -- "| `threshold`                 | Non-linearity      | Moderate-Severe | Asymmetric dynamics             |");
    -- markdown:add(
    -- "| `heavy_tailed`              | Non-Gaussian       | Moderate        | Extreme events                  |");
    -- markdown:add(
    -- "| `time_varying_volatility`   | Heteroskedasticity | Moderate        | Volatility clustering           |");
    -- markdown:add(
    -- "| `long_memory`               | Infinite memory    | Severe          | Multi-year droughts             |");
    -- markdown:add(
    -- "| `jump_diffusion`            | Jump process       | Moderate-Severe | Sudden shocks                   |");
    -- markdown:add(
    -- "| `seasonal_regime_switching` | Season × State     | Severe          | Compound events                 |");
    -- markdown:add(
    -- "| `copula`                    | Tail dependence    | Moderate-Severe | Multi-reservoir                 |");
    -- markdown:add(
    -- "| `mixture`                   | Non-stationarity   | Moderate        | Climate change                  |");
    -- markdown:add(
    -- "| `par_stochastic_volatility` | SV in PAR          | Moderate        | Minimal violation               |");
    -- markdown:add(
    -- "| `levy_process`              | Heavy tails        | Severe          | Infinite variance events        |");
    -- markdown:add(
    -- "| `charr`                     | Range volatility   | Moderate        | Boom-bust cycles                |");
    -- markdown:add(
    -- "| `hidden_markov`             | Multi-state        | Severe          | Complex regimes                 |");
    -- markdown:add(
    -- "| `periodic_threshold`        | Season × Threshold | Severe          | Non-linear seasonality          |");
    -- tab:push(markdown);

    for _, model in ipairs(models) do
        local chart = Chart("Immediate Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/costs_by_category");
                    data = data:select_agents({ 2 });
                    data = data:rename_agents({ label });
                    add_percentile(chart, data, colours[i]);
                    i = i + 1;
                end
            end
        end
        tab:push(chart);
    end

    for _, model in ipairs(models) do
        local chart = Chart("Marginal Cost - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/load_marginal_cost");
                    data = data:aggregate_agents(BY_AVERAGE(), label);
                    add_percentile(chart, data, colours[i]);
                    i = i + 1;
                end
            end
        end
        tab:push(chart);
    end

    for _, model in ipairs(models) do
        local chart = Chart("Deficit - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/deficit");
                    data = data:aggregate_agents(BY_AVERAGE(), label);
                    add_percentile(chart, data, colours[i]);
                    i = i + 1;
                end
            end
        end
        tab:push(chart);
    end

    return tab;
end

local function tab_convergence_analysis()
    local tab = Tab("Convergence Analysis");

    for _, configuration in ipairs(configurations) do
        for _, model in ipairs(models) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local chart = Chart("Convergence - " .. label);
                    local training_progress = generic:load(label .. "/results/training_progress");
                    chart:add("line", training_progress:select_agents({ 1 }));
                    chart:add("line", training_progress:select_agents({ 2 }));
                    tab:push(chart);
                end
            end
        end
    end

    return tab;
end

local function tab_demand_analysis()
    local tab = Tab("Demand Analysis");

    for _, configuration in ipairs(configurations) do
        for _, model in ipairs(models) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

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
    end

    return tab;
end

local function tab_hydro_analysis(agent)
    local tab = Tab("Hydro Analysis (agent " .. agent .. ")");

    local real = generic
        :load(
            configurations[1] .. "/" ..
            models[1] .. "_" ..
            strategies[1] .. "_" ..
            versions[1] .. "/inflow_real_historical"
        )
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

    local chart = Chart("Fake Historical Data");
    for _, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/inflow_fake_historical");
                    data = data:select_agents({ agent });
                    data = data:rename_agents({ configuration .. "/" .. model .. "_" .. strategy });
                    chart:add("line", data);
                end
            end
        end
    end
    tab:push(chart);

    for _, model in ipairs(models) do
        local chart = Chart("Inflow - " .. model);

        local i = 1;
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

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
            end
        end

        tab:push(chart);
    end

    local chart = Chart("Initial Volume");
    local i = 1;
    for _, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/hydro_initial_volume");
                    data = data:select_agents({ agent });
                    data = data:rename_agents({ label });
                    add_percentile(chart, data, colours[i]);

                    i = i + 1;
                end
            end
        end
    end
    tab:push(chart);

    local chart = Chart("Final Volume");
    local i = 1;
    for _, model in ipairs(models) do
        for _, configuration in ipairs(configurations) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local label = get_label(configuration, model, strategy, version);

                    local data = generic:load(label .. "/results/hydro_final_volume");
                    data = data:select_agents({ agent });
                    data = data:rename_agents({ label });
                    add_percentile(chart, data, colours[i]);

                    i = i + 1;
                end
            end
        end
    end
    tab:push(chart);

    -- add_percentile_to_tab(tab, "Hydro Generation", "results/hydro_generation", agent);
    -- add_percentile_to_tab(tab, "Final Volume", "results/hydro_final_volume", agent);

    return tab;
end

local function tab_thermal_analysis(agent)
    local tab = Tab("Thermal Analysis (agent " .. agent .. ")");

    add_percentile_to_tab(tab, "Thermal Generation", "results/thermal_generation", agent);

    return tab;
end

local function tab_seasonal_stats_analysis(agent)
    local tab = Tab("Seasonal Stats (agent " .. agent .. ")");

    local files = {
        { name = "Seasonal Mean - Train",    path = "/inflow_scenarios_seasonal_mean_train" },
        { name = "Seasonal Mean - Simulate", path = "/inflow_scenarios_seasonal_mean_simulate" },
        { name = "Seasonal Std - Train",     path = "/inflow_scenarios_seasonal_std_train" },
        { name = "Seasonal Std - Simulate",  path = "/inflow_scenarios_seasonal_std_simulate" },
    };

    for _, file in ipairs(files) do
        for _, model in ipairs(models) do
            local chart = Chart(file.name .. " - " .. model);

            local i = 1;
            for _, configuration in ipairs(configurations) do
                for _, strategy in ipairs(strategies) do
                    for _, version in ipairs(versions) do
                        local label = get_label(configuration, model, strategy, version);

                        local data = generic:load(label .. file.path);
                        data = data:select_agents({ agent });
                        data = data:rename_agents({ label });
                        chart:add("line", data, { color = colours[i] });
                        i = i + 1;
                    end
                end
            end
            tab:push(chart);
        end
    end

    return tab;
end

local function get_k_from_strategy(strategy)
    local k = string.match(strategy, "stage_wise_k(%d+)");
    if k == nil then
        return 0;
    end
    return tonumber(k);
end

local function add_cluster_chart(tab, label, filename, title_suffix, n_clusters)
    local chart = Chart("Cluster sizes - " .. label .. title_suffix);
    local data = generic:load(label .. "/" .. filename);
    for cluster = 1, n_clusters do
        local series = data:select_agents({ cluster });
        series = series:rename_agents({ "cluster_" .. cluster });
        chart:add("area_stacking", series, { color = colours[cluster] });
    end
    tab:push(chart);
end

local function tab_clustering_analysis()
    local tab = Tab("Clustering Analysis");

    for _, configuration in ipairs(configurations) do
        for _, model in ipairs(models) do
            for _, strategy in ipairs(strategies) do
                for _, version in ipairs(versions) do
                    local k = get_k_from_strategy(strategy);
                    if k > 0 then
                        local label = get_label(configuration, model, strategy, version);

                        add_cluster_chart(tab, label, "inflow_cluster_counts_train", " (train)", k);
                        add_cluster_chart(tab, label, "inflow_cluster_counts_simulate", " (simulate)", k);
                    end
                end
            end
        end
    end

    return tab;
end

local dashboard = Dashboard("PSR");
dashboard:push(tab_demand_analysis());
dashboard:push(tab_cost_analysis());
dashboard:push(tab_convergence_analysis());
dashboard:push(tab_clustering_analysis());
for agent = 1, 1 do
    dashboard:push(tab_hydro_analysis(agent));
    dashboard:push(tab_thermal_analysis(agent));
    -- dashboard:push(tab_seasonal_stats_analysis(agent));
end
dashboard:save("dashboard");
