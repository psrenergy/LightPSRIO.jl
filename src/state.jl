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

    expressions = (
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "aggregate", aggregate,
        "save", save,
    )

    # expressions = [
    #     :ExpressionDataQuiver,
    #     :ExpressionUnary,
    #     :ExpressionBinary,
    #     :ExpressionAggregate,
    # ]

    @push_lua_struct(
        L,
        ExpressionDataQuiver,
        expressions...,
        # "__add", add,
        # "__sub", sub,
        # "__mul", mul,
        # "__div", div,
        # "aggregate", aggregate,
        # "save", save,
    )

    # functions = [
    #     :BY_SUM,
    #     :julia_typeof
    # ]

    # for f in functions
    #     @eval @push_lua_function($L, string($f), $f)
    # end

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
