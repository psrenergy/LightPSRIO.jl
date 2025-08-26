function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

function initialize()
    println("Initializing Lua state...")
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    collections = [
        :Generic,
    ]

    for c in collections
        @eval @push_lua_struct($L, $c, "load", load)
    end

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

    functions = [
        :BY_SUM,
        :julia_typeof
    ]

    for f in functions
        @eval @push_lua_function($L, string($f), $f)
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
