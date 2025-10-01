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
            suffix = join(filter(!=(Symbol(:stage)), keys(kwargs)), " ")
            layers[key] = [Layer(
                "$label ($suffix)",
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

# mutable struct Chart
#     title::String
#     chart_type::String
#     data::Vector{Dict{String, Any}}

#     function Chart(title::String, chart_type::String = "line")
#         return new(title, chart_type, Dict{String, Any}[])
#     end
# end
# @define_lua_struct Chart

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

# function create_patchwork(chart::Chart)
#     # return Html(
#     #     "<div style='margin-top: 1rem; padding: 1rem; background: #f9fafb; border-radius: 0.5rem;'><code>Custom CSS can be added via the dashboard config</code></div>",
#     # )
#     return PatchworkHighcharts(
#         "Monthly Performance",
# """
# {
#     "title": {
#         "text": "U.S Solar Employment Growth",
#         "align": "left"
#     },
#     "yAxis": {
#         "title": {
#             "text": "Number of Employees"
#         }
#     },
#     "xAxis": {
#         "accessibility": {
#             "rangeDescription": "Range: 2010 to 2022"
#         }
#     },
#     "legend": {
#         "layout": "vertical",
#         "align": "right",
#         "verticalAlign": "middle"
#     },
#     "plotOptions": {
#         "series": {
#             "label": {
#                 "connectorAllowed": false
#             },
#             "pointStart": 2010
#         }
#     },
#     "series": [{
#         "name": "Installation & Developers",
#         "data": [
#             43934, 48656, 65165, 81827, 112143, 142383,
#             171533, 165174, 155157, 161454, 154610, 168960, 171558
#         ]
#     }, {
#         "name": "Manufacturing",
#         "data": [
#             24916, 37941, 29742, 29851, 32490, 30282,
#             38121, 36885, 33726, 34243, 31050, 33099, 33473
#         ]
#     }, {
#         "name": "Sales & Distribution",
#         "data": [
#             11744, 30000, 16005, 19771, 20185, 24377,
#             32147, 30912, 29243, 29213, 25663, 28978, 30618
#         ]
#     }, {
#         "name": "Operations & Maintenance",
#         "data": [
#             null, null, null, null, null, null, null,
#             null, 11164, 11218, 10077, 12530, 16585
#         ]
#     }, {
#         "name": "Other",
#         "data": [
#             21908, 5548, 8105, 11248, 8989, 11816, 18274,
#             17300, 13053, 11906, 10073, 11471, 11648
#         ]
#     }],
#     "responsive": {
#         "rules": [{
#             "condition": {
#                 "maxWidth": 500
#             },
#             "chartOptions": {
#                 "legend": {
#                     "layout": "horizontal",
#                     "align": "center",
#                     "verticalAlign": "bottom"
#                 }
#             }
#         }]
#     }
# }
# """
#         # Dict{String, Any}(
#         #     "chart" => Dict("type" => "line"),
#         #     "title" => Dict("text" => ""),
#         #     "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]),
#         #     "yAxis" => Dict("title" => Dict("text" => "Value")),
#         #     "series" => [
#         #         Dict("name" => "Series A", "data" => [29, 71, 106, 129, 144, 176]),
#         #         Dict("name" => "Series B", "data" => [50, 80, 95, 110, 130, 150]),
#         #     ],
#         # ),
#     )
# end