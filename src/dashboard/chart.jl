mutable struct Chart
    title::String
    chart_type::String
    layers::Vector{Layer}

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

    return """{
        "title": "$(escape_json(chart.title))",
        "chart_type": "$(escape_json(chart.chart_type))",
        "data": [$(join(data_json, ", "))]
    }"""
end

function add(chart::Chart, expression::AbstractExpression)
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