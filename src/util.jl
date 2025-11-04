function escape_json(str::String)
    return replace(
        replace(
            replace(str, "\\" => "\\\\"),
            "\"" => "\\\""),
        "\n" => "\\n",
    )
end

function to_json_string(options::Optional{Dict})
    if isnothing(options)
        return ""
    else
        json = JSON.json(options)
        return string(json[2:(end-1)], ",")
    end
end

function kwargs_to_key(excluding::Set{Symbol}; kwargs...)
    key = Vector{Int}()
    for (dimension, value) in pairs(kwargs)
        if !(dimension in excluding)
            push!(key, value)
        end
    end
    return key
end
