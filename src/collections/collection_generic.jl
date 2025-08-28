mutable struct Generic
    case_index::Int
    path::String

    function Generic(L::LuaState, case_index::Integer = 1)
        path = get_case_path(L, case_index)
        return new(case_index, path)
    end
end
@define_lua_struct_with_state Generic

function load(generic::Generic, filename::String)
    return ExpressionDataQuiver(generic.path, filename)
end
@define_lua_function load
