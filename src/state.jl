function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

function initialize(paths::Vector{String})
    println("Initializing Lua state...")
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Case)
    @push_lua_struct(L, Generic, "load", load)

    @push_lua_struct(
        L,
        ExpressionDataQuiver,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "__pow", pow,
        # "__unm", unm,
        "aggregate", aggregate,
        "aggregate_agents", aggregate_agents,
        "save", save,
    )

    # @push_lua_struct(
    #     L,
    #     ExpressionUnary,
    #     "__add", add,
    #     "__sub", sub,
    #     "__mul", mul,
    #     "__div", div,
    #     "__pow", pow,
    #     # "__unm", unm,
    #     "aggregate", aggregate,
    #     "aggregate_agents", aggregate_agents,
    #     "save", save,
    # )

    @push_lua_struct(
        L,
        ExpressionBinary,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "__pow", pow,
        # "__unm", unm,
        "aggregate", aggregate,
        "aggregate_agents", aggregate_agents,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionAggregateDimensions,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "__pow", pow,
        # "__unm", unm,
        "aggregate", aggregate,
        "aggregate_agents", aggregate_agents,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionAggregateAgents,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "__pow", pow,
        # "__unm", unm,
        "aggregate", aggregate,
        "aggregate_agents", aggregate_agents,
        "save", save,
    )

    @push_lua_struct(
        L,
        ExpressionConcatenateAgents,
        "__add", add,
        "__sub", sub,
        "__mul", mul,
        "__div", div,
        "__pow", pow,
        # "__unm", unm,
        "aggregate", aggregate,
        "aggregate_agents", aggregate_agents,
        "save", save,
    )

    @push_lua_function(L, "BY_SUM", BY_SUM)
    @push_lua_function(L, "BY_AVERAGE", BY_AVERAGE)
    @push_lua_function(L, "BY_MIN", BY_MIN)
    @push_lua_function(L, "BY_MAX", BY_MAX)
    @push_lua_function(L, "julia_typeof", julia_typeof)
    @push_lua_function(L, "concatenate_agents", concatenate_agents)
    @push_lua_enumx(L, AggregateFunction)

    @push_lua_struct(
        L,
        Chart,
    )

    @push_lua_struct(
        L,
        Tab,
        "push", push
    )

    @push_lua_struct(
        L,
        Dashboard,
        "push", push,
        "save", save,
    )

    register_cases(L, paths)

    return L
end

function run_script(L::LuaState, script::String)
    LuaNova.safe_script(L, script)
    return nothing
end

function run_file(L::LuaState, path::String)
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
