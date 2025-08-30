struct Case
    path::String
end
@define_lua_struct Case

function register_cases(L::LuaState, paths::Vector{String})
    buffer = IOBuffer()
    println(buffer, "__CASES__ = {};")
    println(buffer, "setmetatable(")
    println(buffer, "    __CASES__,")
    println(buffer, "    {")
    println(buffer, "        __index = {")
    for path in paths
        println("Opening case at path: $path")
        escaped_path = replace(path, "\\" => "\\\\")
        println(buffer, "            Case(\"$escaped_path\")")
    end
    println(buffer, "        },")
    println(buffer, "        __newindex = function(t, k, v) error(\"Attempt to modify a read-only table.\", 2) end,")
    println(buffer, "        __metatable = \"This table is read-only.\"")
    println(buffer, "    }")
    println(buffer, ")")
    LuaNova.safe_script(L, String(take!(buffer)))

    return nothing
end

function get_case(L::LuaState, case_index::Integer)
    LuaNova.get_global(L, "__CASES__")
    LuaNova.push_to_lua!(L, case_index)
    LuaNova.get_table(L, -2)
    case = LuaNova.to_userdata(L, -1, Case)
    LuaNova.lua_pop!(L, 1)
    return case
end
