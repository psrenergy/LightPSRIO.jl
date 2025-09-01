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

function json_encode_dashboard(tab::Tab)
    charts_json = String[]

    for chart in tab.charts
        chart_json = json_encode_dashboard(chart)
        push!(charts_json, chart_json)
    end

    return """{
        "label": "$(escape_json(tab.label))",
        "charts": [$(join(charts_json, ", "))]
    }"""
end
