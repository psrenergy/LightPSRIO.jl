abstract type AbstractChart end

function add(chart::AbstractChart, expression::AbstractExpression)
    if !has_data(expression)
        return nothing
    end

    attributes = expression.attributes
    println("Adding layer ($attributes)")

    date_reference = DateReference(
        StageType.MONTH,
        Dates.month(attributes.initial_date),
        Dates.year(attributes.initial_date),
    )

    layers = Dict{Vector{Int}, Vector{Layer}}()

    start!(expression)
    for kwargs in eachindex(expression)
        key = Vector{Int}()
        for (dimension, value) in pairs(kwargs)
            if dimension != :stage
                push!(key, value)
            end
        end

        if !haskey(layers, key)
            suffix = join(filter(!=(Symbol(:stage)), keys(kwargs)), " ")
            layers[key] = [Layer(
                "$label ($suffix)",
                SeriesType.Line,
                date_reference,
            ) for label in attributes.labels]
        end

        result = evaluate(expression; kwargs...)
        for (i, layer) in enumerate(layers[key])
            add(layer, kwargs[:stage], result[i])
        end
    end
    finish!(expression)

    for layer_group in values(layers)
        for layer in layer_group
            push!(chart.layers, layer)
        end
    end

    return nothing
end
@define_lua_function add

mutable struct ChartJS <: AbstractChart
    title::String
    chart_type::String
    layers::Vector{Layer}

    function ChartJS(title::String, chart_type::String = "line")
        return new(title, chart_type, Layer[])
    end
end
@define_lua_struct ChartJS

function json_encode_dashboard(chart::ChartJS)
    layers_json = String[]
    for layer in chart.layers
        data_points = []
        for (timestamp, value) in layer.values
            push!(data_points, "{\"x\": $timestamp, \"y\": $value}")
        end
        data_json = "[" * join(data_points, ", ") * "]"

        layer_json = """{
            "label": "$(escape_json(layer.label))",
            "data": $data_json
        }"""
        push!(layers_json, layer_json)
    end

    return """{
        "title": "$(escape_json(chart.title))",
        "chart_type": "$(escape_json(chart.chart_type))",
        "library": "chartjs",
        "layers": [$(join(layers_json, ", "))]
    }"""
end

mutable struct Highcharts <: AbstractChart
    title::String
    chart_type::String
    layers::Vector{Layer}

    function Highcharts(title::String, chart_type::String = "line")
        return new(title, chart_type, Layer[])
    end
end
@define_lua_struct Highcharts

function json_encode_dashboard(chart::Highcharts)
    layers_json = String[]
    for layer in chart.layers
        push!(layers_json, encode_highcharts(layer))
    end

    return """{
        "title": "$(escape_json(chart.title))",
        "chart_type": "highcharts",
        "library": "highcharts",
        "layers": [$(join(layers_json, ", "))]
    }"""
end

# Chart type used to determine which library to use
function get_chart_library(chart::AbstractChart)
    if isa(chart, ChartJS)
        return "chartjs"
    elseif isa(chart, Highcharts)
        return "highcharts"
    else
        return "unknown"
    end
end
