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
    return json[2:end-1]
end