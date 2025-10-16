@enumx AggregateType begin
    Sum
    Average
    Min
    Max
    Percentile
end

@kwdef struct AggregateFunction
    type::AggregateType.T
    parameter::Optional{Float64} = nothing
end
@define_lua_struct AggregateFunction

function BY_SUM()
    return AggregateFunction(type = AggregateType.Sum)
end
@define_lua_function BY_SUM

function BY_AVERAGE()
    return AggregateFunction(type = AggregateType.Average)
end
@define_lua_function BY_AVERAGE

function BY_MIN()
    return AggregateFunction(type = AggregateType.Min)
end
@define_lua_function BY_MIN

function BY_MAX()
    return AggregateFunction(type = AggregateType.Max)
end
@define_lua_function BY_MAX

function BY_PERCENTILE(parameter::Float64)
    return AggregateFunction(type = AggregateType.Percentile, parameter = parameter / 100)
end
@define_lua_function BY_PERCENTILE