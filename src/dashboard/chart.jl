abstract type AbstractChart end

function add_line(chart::AbstractChart, expression::AbstractExpression)
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
            @show dimensions_label = get_filtered_dimensions_label(attributes, kwargs)
            layers[key] = [
                Layer(
                    length(dimensions_label) > 0 ? "$label ($dimensions_label)" : "$label",
                    SeriesType.Line,
                    date_reference,
                    attributes.unit,
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
@define_lua_function add_line

mutable struct Chart <: AbstractChart
    title::String
    layers::Vector{Layer}

    function Chart(title::String)
        return new(title, Dict{String, Any}[])
    end
end
@define_lua_struct Chart

function create_patchwork(chart::Chart)
    series = "[" * join([create_patchwork(layer) for layer in chart.layers], ",\n") * "]"
    return PatchworkHighcharts(
        "Monthly Performance",
        """
        {
            "xAxis": {
                "type": "datetime"
            },
            "legend": { "layout": "vertical", "align": "right", "verticalAlign": "top" },
            "series": $series,
            "responsive": {
                "rules": [{
                    "condition": {
                        "maxWidth": 500
                    },
                    "chartOptions": {
                        "legend": {
                            "layout": "horizontal",
                            "align": "center",
                            "verticalAlign": "bottom"
                        }
                    }
                }]
            }
        }
        """,
    )
end
