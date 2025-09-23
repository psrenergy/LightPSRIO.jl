struct Layer
    label::String
    type::SeriesType.T
    date_reference::DateReference
    unit::String
    values::Vector{Base.Tuple{Int, Float64}}

    function Layer(label::String, type::SeriesType.T, date_reference::DateReference, unit::String)
        return new(
            label,
            type,
            date_reference,
            unit,
            Vector{Base.Tuple{Int, Float64}}(),
        )
    end
end

function add(layer::Layer, time_dimension::Integer, value::Real)
    epoch = PSRDates.stage_to_epoch(layer.date_reference, time_dimension)
    push!(layer.values, (epoch, value))
    return nothing
end

function encode_echarts(layer::Layer)
    name = layer.label
    type = layer.type
    data = join(("[$(t[1]), $(t[2])]" for t in layer.values), ", ")
    return """{
      name: '$name',
      type: '$type',
      data: [$data],
    }"""
end

function encode_highcharts(layer::Layer)
    name = layer.label
    type = layer.type == SeriesType.Line ? "line" : string(layer.type)
    data = join(("[$(t[1]), $(t[2])]" for t in layer.values), ", ")
    point_start = isempty(layer.values) ? 0 : layer.values[1][1]

    return """{
        "name": "$name",
        "data": [$data],
        "domain": "week",
        "lineWidth": 2.0,
        "pointStart": $point_start,
        "type": "$type",
        "unique_tag": "$name",
        "yUnit": ""
    }"""
end
