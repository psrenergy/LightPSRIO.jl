mutable struct Dashboard
    tabs::Vector{Tab}

    function Dashboard()
        return new(Tab[])
    end
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

    patchwork = Patchwork.Dashboard(
        "Dashboard",
        [create_patchwork(tab) for tab in dashboard.tabs],
    )
    Patchwork.save(patchwork, path)

    return nothing
end
@define_lua_function save
