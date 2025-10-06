@kwdef struct Layer
    label::String
    type::SeriesType.T
    date_reference::DateReference
    unit::String
    options::Optional{Dict}
    values::Vector{Base.Tuple{Int, Float64}} = []
end

function add(layer::Layer, time_dimension::Integer, value::Real)
    epoch = PSRDates.stage_to_epoch(layer.date_reference, time_dimension)
    push!(layer.values, (epoch, value))
    return nothing
end

function get_data_string(layer::Layer)
    return "[" * join(("[$(t[1]), $(@sprintf("%.3f", t[2]))]" for t in layer.values), ", ") * "]"
end

function create_patchwork(layer::Layer)
    options = isnothing(layer.options) ? "" : string(to_json_string(layer.options), ",")
    data = get_data_string(layer)

    return """
{
    "name": "$(layer.label)",    
    $options
    $(highcharts(layer.type))
    $(highcharts(layer.date_reference.stage_type))
    "tooltip": { "valueSuffix": " $(layer.unit)" },
    "data": $data
}
"""
end

# function encode_echarts(layer::Layer)
#     name = layer.label
#     type = layer.type
#     data = join(("[$(t[1]), $(t[2])]" for t in layer.values), ", ")
#     return """{
#       name: '$name',
#       type: '$type',
#       data: [$data],
#     }"""
# end

# function encode_highcharts(layer::Layer)
#     name = layer.label
#     type = layer.type == SeriesType.Line ? "line" : string(layer.type)
#     data = join(("[$(t[1]), $(t[2])]" for t in layer.values), ", ")
#     point_start = isempty(layer.values) ? 0 : layer.values[1][1]

#     return """{
#         "name": "$name",
#         "data": [$data],
#         "domain": "week",
#         "lineWidth": 2.0,
#         "pointStart": $point_start,
#         "type": "$type",
#         "unique_tag": "$name",
#         "yUnit": ""
#     }"""
# end
