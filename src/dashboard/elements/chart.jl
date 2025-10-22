abstract type AbstractChart <: AbstractElement end

function add(chart::AbstractChart, type::String, e1::AbstractExpression, options::Optional{Dict} = nothing)
    if !has_data(e1)
        return nothing
    end

    e1 = resolve_units(e1)

    attributes = e1.attributes
    excluding = Set([attributes.time_dimension])
    println("Adding layer ($attributes)")

    date_reference = get_date_reference(attributes)

    layers = Dict{Vector{Int}, Vector{Layer1}}()

    start!(e1)
    for kwargs in eachindex(e1)
        key = kwargs_to_key(excluding; kwargs...)

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

        result = evaluate(e1; kwargs...)
        for (i, layer) in enumerate(layers[key])
            add(layer, kwargs[attributes.time_dimension], result[i])
        end
    end
    finish!(e1)

    for layer_group in values(layers)
        for layer in layer_group
            push!(chart.layers, layer)
        end
    end

    return nothing
end

function add(chart::AbstractChart, type::String, e1::AbstractExpression, e2::AbstractExpression, options::Optional{Dict} = nothing)
    if !has_data(e1) || !has_data(e2)
        return nothing
    end

    e1 = resolve_units(e1)
    e2 = resolve_units(e2)

    attributes = e1.attributes
    excluding = Set([attributes.time_dimension])
    println("Adding layer ($attributes)")

    date_reference = get_date_reference(attributes)

    layers = Dict{Vector{Int}, Vector{Layer2}}()

    start!(e1)
    start!(e2)
    for kwargs in eachindex(e1)
        key = kwargs_to_key(excluding; kwargs...)

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

        result1 = evaluate(e1; kwargs...)
        result2 = evaluate(e2; kwargs...)
        for (i, layer) in enumerate(layers[key])
            add(layer, kwargs[attributes.time_dimension], result1[i], result2[i])
        end
    end
    finish!(e1)
    finish!(e2)

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
    if length(chart.layers) == 0
        return Patchwork.Markdown("No data to display")
    end

    series = "[" * join([create_patchwork(layer) for layer in chart.layers], ",\n") * "]"
    units = unique([layer.unit for layer in chart.layers])

    # "boost": { "enabled": true, "useGPUTranslations": true, "usePreAllocated": true, "allowForce": true, "seriesThreshold": 2048 },

    return Highcharts(
        chart.title,
        """
        {
            "title": { "text": null },
            "chart": {
                "animation": false,
                "zoomType": "x",
                "panning": true,
                "panKey": "shift"
            },
            "xAxis": {
                "type": "datetime"
            },
            "yAxis": {
                "title": { "text": "$(units[1])" }
            },
            "legend": { "layout": "vertical", "align": "right", "verticalAlign": "top" },
            "plotOptions": {
                "series": {
                    "marker": {
                        "enabled": false
                    },
                    "states": {
                        "inactive": {
                            "opacity": 1
                        }
                    }                        
                }
            },
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
            },
            "credits": { "enabled": false }
        }
        """,
    )
end
