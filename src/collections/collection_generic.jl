mutable struct Generic
    case_index::Int
    path::String

    function Generic(L::LuaState, case_index::Number = 1)
        case = get_case(L, case_index)
        return new(case_index, case.path)
    end
end
@define_lua_struct Generic

function load(generic::Generic, filename::String)
    return ExpressionDataQuiver(generic.path, filename)
end
@define_lua_function load

function load_string(generic::Generic, filename::String)
    path = joinpath(generic.path, filename)
    if !isfile(path)
        error("File '$filename' not found in case path.")
    end
    return read(path, String)
end
@define_lua_function load_string
