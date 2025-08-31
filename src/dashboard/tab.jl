mutable struct Tab
    label::String
    charts::Vector{Chart}

    function Tab(label::String)
        return new(label, Chart[])
    end
end
@define_lua_struct Tab

function push(tab::Tab, chart::Chart)
    push!(tab.charts, chart)
    return nothing
end
@define_lua_function push
