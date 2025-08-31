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
