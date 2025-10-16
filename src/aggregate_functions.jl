@enumx AggregateType begin
    Sum
    Average
    Min
    Max
    Percentile
end

@enumx ProfileType begin
    Day
    Week
    Month
    Year
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

@kwdef struct ProfileFunction
    type::ProfileType.T
    aggregate_function::AggregateFunction
end
@define_lua_struct ProfileFunction

function BY_DAY(aggregate_function::AggregateFunction)
    return ProfileFunction(type = ProfileType.Day, aggregate_function = aggregate_function)
end
@define_lua_function BY_DAY

function BY_WEEK(aggregate_function::AggregateFunction)
    return ProfileFunction(type = ProfileType.Week, aggregate_function = aggregate_function)
end
@define_lua_function BY_WEEK

function BY_MONTH(aggregate_function::AggregateFunction)
    return ProfileFunction(type = ProfileType.Month, aggregate_function = aggregate_function)
end
@define_lua_function BY_MONTH

function BY_YEAR(aggregate_function::AggregateFunction)
    return ProfileFunction(type = ProfileType.Year, aggregate_function = aggregate_function)
end
@define_lua_function BY_YEAR
