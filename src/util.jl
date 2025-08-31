Optional{T} = Union{T, Nothing}

function escape_json(str::String)
    return replace(replace(replace(str, "\\" => "\\\\"), "\"" => "\\\""), "\n" => "\\n")
end
