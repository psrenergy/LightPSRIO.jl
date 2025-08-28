mutable struct Generic
    case_index::Int
    path::String

    function Generic(L::LuaState, case_index::Integer = 1)
        LuaNova.get_global(L, "__PATHS__[1]")
        @show path = LuaNova.to_string(L, -1)
        return new(case_index, path)
    end
end

@define_lua_struct_with_state Generic

function load(generic::Generic, filename::String)
    path = raw"C:\Development\PSRIO\LightPSRIO.jl\test\data"
    return ExpressionDataQuiver(path, filename)
end
@define_lua_function load
