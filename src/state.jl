function initialize()
    println("Initializing Lua state...")
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    println("Registering Generic collection...")
    @push_lua_struct(
        L, Generic,
        "load", load,
    )

    println("Registering ExpressionDataQuiver...")
    @push_lua_struct(
        L, ExpressionDataQuiver,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "save", save,
    )

    println("Registering ExpressionBinary...")
    @push_lua_struct(
        L, ExpressionBinary,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "save", save,
    )

    return L
end

function push_case!(case::String)
    push!(cases, case)
    return nothing
end

function run(L, script::String)
    LuaNova.safe_script(L, script)
    return nothing
end

function finalize(L)
    LuaNova.close(L)
    return nothing
end
