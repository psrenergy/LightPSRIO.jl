@enumx SeriesType begin
    Line
    AreaStacking
end

function to_series_type(type::String)
    if type == "line"
        return SeriesType.Line
    elseif type == "area_stacking"
        return SeriesType.AreaStacking
    else
        error("Unsupported series type: $type")
    end
end

function highcharts(type::SeriesType.T)
    if type == SeriesType.Line
        return """
"type": "line",
        """
    elseif type == SeriesType.AreaStacking
        return """
"type": "area",
"stacking": "normal",
        """
    else
        error("Unsupported series type: $type")
    end
end