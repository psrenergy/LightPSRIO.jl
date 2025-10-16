function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

function initialize(paths::Vector{String}; logger = Logging.Info)
    global_logger(ConsoleLogger(logger))

    @debug "Initializing Lua state..."
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Case)

    @push_lua_structs(
        L,
        [
            Generic,
        ],
        "load", load
    )

    @push_lua_structs(
        L,
        [
            ExpressionNull,
            # data expressions
            ExpressionDataQuiver,
            # unary expressions
            ExpressionAggregateAgents,
            ExpressionAggregateDimensions,
            ExpressionConvert,
            ExpressionProfile,
            ExpressionRenameAgents,
            ExpressionSelectAgents,
            ExpressionSetAttribute,
            # binary expressions
            ExpressionBinary,
            # variadic expressions
            ExpressionConcatenate,
            ExpressionConcatenateAgents,
        ],
        # data expressions
        # unary expressions
        "add_suffix", add_suffix,
        "aggregate_agents", aggregate_agents,
        "aggregate", aggregate,
        "convert", convert,
        "day_profile", day_profile,
        "month_profile", month_profile,
        "rename_agents", rename_agents,
        "repeat", repeat,
        "select_agents", select_agents,
        "set_initial_year", set_initial_year,
        "week_profile", week_profile,
        "year_profile", year_profile,
        # binary expressions
        "__add", add,
        "__div", div,
        "__mul", mul,
        "__pow", pow,
        "__sub", sub,
        # variadic expressions
        # abstract 
        "save", save,
        # other
        "has_data", has_data,
    )

    @push_lua_function(L, "BY_SUM", BY_SUM)
    @push_lua_function(L, "BY_AVERAGE", BY_AVERAGE)
    @push_lua_function(L, "BY_MIN", BY_MIN)
    @push_lua_function(L, "BY_MAX", BY_MAX)
    @push_lua_function(L, "BY_PERCENTILE", BY_PERCENTILE)
    @push_lua_function(L, "concatenate", concatenate)
    @push_lua_function(L, "concatenate_agents", concatenate_agents)
    @push_lua_function(L, "concatenate", concatenate)
    @push_lua_function(L, "julia_typeof", julia_typeof)

    @push_lua_struct(L, AggregateFunction)

    @push_lua_struct(
        L,
        Markdown,
        "add", add
    )

    @push_lua_struct(
        L,
        Chart,
        "add", add
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
