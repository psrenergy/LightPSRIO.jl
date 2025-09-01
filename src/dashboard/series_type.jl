@enumx SeriesType Line

function encode_echarts(series_type::SeriesType.T)
    if series_type == SeriesType.Line
        return "line"
    else
        error("Unsupported series type: $series_type")
    end
end
