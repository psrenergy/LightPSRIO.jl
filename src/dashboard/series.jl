struct Series
    label::String
    type::SeriesType.T
    date_reference::DateReference
    values::Vector{Base.Tuple{Int, Float64}}

    function Series(label::String, type::SeriesType.T, date_reference::DateReference)
        return new(
            label,
            type,
            date_reference,
            Vector{Base.Tuple{Int, Float64}}(),
        )
    end
end

function add(series::Series, time_dimension::Integer, value::Float64)
    epoch = PSRDates.stage_to_epoch(series.date_reference, time_dimension)
    push!(series.values, (epoch, value))
    return nothing
end

function encode_echarts(series::Series)
    name = series.label
    type = series.type
    data = join(("[$(t[1]), $(t[2])]" for t in series.values), ", ")
    return """{
      name: '$name',
      type: '$type',
      data: [$data],
    }"""
end
