mutable struct Dashboard
    title::String
    tabs::Vector{Tab}

    function Dashboard(title::String)
        return new(title, Tab[])
    end
end

function Dashboard()
    return Dashboard("PSRIO")
end
@define_lua_struct Dashboard

function push(dashboard::Dashboard, tab::Tab)
    push!(dashboard.tabs, tab)
    return nothing
end
@define_lua_function push

function save(L::LuaState, dashboard::Dashboard, filename::String)
    case = get_case(L, 1)

    path = joinpath(case.path, "$filename.html")
    # path = joinpath(raw"C:\Development\PSRIO\LightPSRIO.jl", "$filename.html")

    patchwork = Patchwork.Dashboard(
        dashboard.title,
        [create_patchwork(tab) for tab in dashboard.tabs],
    )
    Patchwork.save(patchwork, path)

    return nothing
end
@define_lua_function save
