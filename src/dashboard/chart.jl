mutable struct Chart
    title::String
    chart_type::String
    data::Vector{Dict{String, Any}}

    function Chart(title::String, chart_type::String = "line")
        return new(title, chart_type, Dict{String, Any}[])
    end
end
@define_lua_struct Chart

function add_data(chart::Chart, label::String, value::Float64)
    push!(chart.data, Dict("label" => label, "value" => value))
    return nothing
end
@define_lua_function add_data

function json_encode_dashboard(chart::Chart)
    data_json = String[]
    for data_point in chart.data
        point_parts = String[]
        for (key, value) in data_point
            if isa(value, String)
                push!(point_parts, "\"$(key)\": \"$(escape_json(value))\"")
            else
                push!(point_parts, "\"$(key)\": $(value)")
            end
        end
        push!(data_json, "{" * join(point_parts, ", ") * "}")
    end

    chart_json = """{
        "title": "$(escape_json(chart.title))",
        "chart_type": "$(escape_json(chart.chart_type))",
        "data": [$(join(data_json, ", "))]
    }"""

    return chart_json
end
