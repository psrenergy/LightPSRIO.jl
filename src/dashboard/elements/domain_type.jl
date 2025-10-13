function highcharts(type::StageType.T)
    if type == StageType.MONTH
        return """
"pointInterval": $(60000 * 60 * 24 * 31),
"pointIntervalUnit": "month",
"""
    else
        error("Unsupported stage type: $type")
    end
end
