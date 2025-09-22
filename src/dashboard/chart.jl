mutable struct Chart
    title::String
    chart_type::String
    layers::Vector{Layer}

    function Chart(title::String, chart_type::String = "line")
        return new(title, chart_type, Dict{String, Any}[])
    end
end
@define_lua_struct Chart

# function add_data(chart::Chart, label::String, value::Float64)
#     push!(chart.data, Dict("label" => label, "value" => value))
#     return nothing
# end
# @define_lua_function add_data

# function json_encode_dashboard(chart::Chart)
#     data_json = String[]
#     for data_point in chart.data
#         point_parts = String[]
#         for (key, value) in data_point
#             if isa(value, String)
#                 push!(point_parts, "\"$(key)\": \"$(escape_json(value))\"")
#             else
#                 push!(point_parts, "\"$(key)\": $(value)")
#             end
#         end
#         push!(data_json, "{" * join(point_parts, ", ") * "}")
#     end

#     return """{
#         "title": "$(escape_json(chart.title))",
#         "chart_type": "$(escape_json(chart.chart_type))",
#         "data": [$(join(data_json, ", "))]
#     }"""
# end

function add(layer::Layer, expression::AbstractExpression)
    if !has_data(expression)
        return nothing
    end

    attributes = expression.attributes
    println("Adding layer ($attributes)")

    writer = Quiver.Writer{Quiver.binary}(
        joinpath(case.path, filename);
        labels = attributes.labels,
        dimensions = string.(attributes.dimensions),
        time_dimension = "stage",
        dimension_size = attributes.dimension_size,
        initial_date = attributes.initial_date,
        unit = attributes.unit,
        # frequency = metadata.frequency,
    )

    date_reference = DateReference(
        StageType.MONTH,
        Dates.month(attributes.initial_date),
        Dates.year(attributes.initial_date),
    )

    # layer = Series(
    #     "Test Series",
    #     LightPSRIO.SeriesType.Line,
    #     date_reference
    # )

    start!(e)
    for kwargs in eachindex(e)
        @show kwargs
        result = evaluate(e; kwargs...)
    end
    finish!(e)

    return nothing
end