function highcharts(type::StageType.T)
    if type == StageType.MONTH
        return """
"pointInterval": $(60000 * 60 * 24 * 31),
"pointIntervalUnit": "month",
"""
    elseif type == StageType.YEAR
        return """
"pointInterval": $(60000 * 60 * 24 * 365),
"pointIntervalUnit": "year",
"""
    else
        throw(ArgumentError("Unsupported stage type: $type"))
    end
end
