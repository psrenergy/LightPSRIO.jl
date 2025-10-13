function escape_json(str::String)
    return replace(
        replace(
            replace(str, "\\" => "\\\\"),
            "\"" => "\\\""),
        "\n" => "\\n",
    )
end

function to_json_string(dict::Dict)
    json = JSON.json(dict)
    return json[2:(end-1)]
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
