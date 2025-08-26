mutable struct Generic
    case_index::Int
end
function Generic()
    return Generic(1)
end
@define_lua_struct Generic

function load(generic::Generic, filename::String)
    path = cases[generic.case_index]
    return ExpressionDataQuiver(path, filename)
end
@define_lua_function load
