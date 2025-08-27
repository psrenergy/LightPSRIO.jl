function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

function initialize()
    println("Initializing Lua state...")
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Generic, "load", load)

    @push_lua_struct(
        L,
        ExpressionDataQuiver,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "aggregate", aggregate,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionUnary,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "aggregate", aggregate,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionBinary,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "aggregate", aggregate,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionAggregate,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "aggregate", aggregate,
        "save", save,
    )

    @push_lua_function(L, "BY_SUM", BY_SUM)
    @push_lua_function(L, "julia_typeof", julia_typeof)
    @push_lua_enumx(L, AggregateFunction)

    return L
end

function push_case!(case::String)
    push!(cases, case)
    return nothing
end

function run_script(L, script::String)
    LuaNova.safe_script(L, script)
    return nothing
end

function run_file(L, path::String)
    open(path) do file
        script = read(file, String)
        return LuaNova.safe_script(L, script)
    end
    return nothing
end

function finalize(L)
    LuaNova.close(L)
    return nothing
end
