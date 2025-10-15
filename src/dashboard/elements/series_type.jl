@enumx SeriesType begin
    Line
    AreaStacking
    AreaRange
    Column
end

function to_series_type(type::String)
    if type == "line"
        return SeriesType.Line
    elseif type == "area_stacking"
        return SeriesType.AreaStacking
    elseif type == "area_range"
        return SeriesType.AreaRange
    elseif type == "column"
        return SeriesType.Column
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
    elseif type == SeriesType.AreaRange
        return """
"type": "arearange",
        """
    elseif type == SeriesType.Column
        return """
"type": "column",
        """
    else
        error("Unsupported series type: $type")
    end
end
