abstract type AbstractChart <: AbstractElement end

function add(chart::AbstractChart, type::String, expression::AbstractExpression, options::Optional{Dict} = nothing)
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

    layers = Dict{Vector{Int}, Vector{Layer1}}()

    start!(expression)
    for kwargs in eachindex(expression)
        key = Vector{Int}()
        for (dimension, value) in pairs(kwargs)
            if dimension != :stage
                push!(key, value)
            end
        end

        if !haskey(layers, key)
            dimensions_label = get_filtered_dimensions_label(attributes, kwargs)
            layers[key] = [
                Layer1(
                    label = length(dimensions_label) > 0 ? "$label ($dimensions_label)" : "$label",
                    type = to_series_type(type),
                    date_reference = date_reference,
                    unit = attributes.unit,
                    options = options,
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

function add(chart::AbstractChart, type::String, expression1::AbstractExpression, expression2::AbstractExpression, options::Optional{Dict} = nothing)
    if !has_data(expression1) || !has_data(expression2)
        return nothing
    end

    attributes = expression1.attributes
    println("Adding layer ($attributes)")

    date_reference = DateReference(
        StageType.MONTH,
        Dates.month(attributes.initial_date),
        Dates.year(attributes.initial_date),
    )

    layers = Dict{Vector{Int}, Vector{Layer2}}()

    start!(expression1)
    start!(expression2)
    for kwargs in eachindex(expression1)
        key = Vector{Int}()
        for (dimension, value) in pairs(kwargs)
            if dimension != :stage
                push!(key, value)
            end
        end

        if !haskey(layers, key)
            dimensions_label = get_filtered_dimensions_label(attributes, kwargs)
            layers[key] = [
                Layer2(
                    label = length(dimensions_label) > 0 ? "$label ($dimensions_label)" : "$label",
                    type = to_series_type(type),
                    date_reference = date_reference,
                    unit = attributes.unit,
                    options = options,
                ) for label in attributes.labels]
        end

        result1 = evaluate(expression1; kwargs...)
        result2 = evaluate(expression2; kwargs...)
        for (i, layer) in enumerate(layers[key])
            add(layer, kwargs[:stage], result1[i], result2[i])
        end
    end
    finish!(expression1)
    finish!(expression2)

    for layer_group in values(layers)
        for layer in layer_group
            push!(chart.layers, layer)
        end
    end

    return nothing
end
@define_lua_function add

mutable struct Chart <: AbstractChart
    title::String
    layers::Vector{AbstractLayer}

    function Chart(title::String)
        return new(title, Dict{String, Any}[])
    end
end
@define_lua_struct Chart

function create_patchwork(chart::Chart)
    series = "[" * join([create_patchwork(layer) for layer in chart.layers], ",\n") * "]"
    units = unique([layer.unit for layer in chart.layers])

    return Patchwork.Highcharts2(
        chart.title,
        """
        {
            "title": { "text": null },
            "xAxis": {
                "type": "datetime"
            },
            "yAxis": {
                "title": { "text": "$(units[1])" }
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
