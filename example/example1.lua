local generic = Generic();

local function tab_home()
    local tab = Tab("Home");
    return tab;
end

local function tab_cost_analysis()
    local tab = Tab("Cost Analysis");
    return tab;
end

local function tab_demand_analysis()
    local tab = Tab("Demand Analysis");

    return tab;
end

local function tab_hydro_analysis()
    local tab = Tab("Hydro Analysis");

    return tab;
end

local function tab_thermal_analysis()
    local tab = Tab("Thermal Analysis");
    return tab;
end

local function tab_renewable_analysis()
    local tab = Tab("Renewable Analysis");
    return tab;
end

local dashboard = Dashboard();
dashboard:push(tab_home());
dashboard:save("dashboard");
