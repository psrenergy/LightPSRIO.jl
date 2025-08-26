function initialize()
    println("Initializing Lua state...")
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    println("Registering Generic collection...")
    @push_lua_struct(
        L,
        Generic,
        "load", load,
    )

    expressions = [
        :ExpressionDataQuiver,
        :ExpressionUnary,
        :ExpressionBinary,
        :ExpressionAggregate,
    ]

    for e in expressions
        @eval @push_lua_struct(
            $L,
            $e,
            "__add", add,
            "__sub", sub,
            "__mul", mul,
            "__div", div,
            "aggregate", aggregate,
            "save", save,
        )
    end

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
