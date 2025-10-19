mutable struct ExpressionAggregateAgents <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    aggregate_function::AggregateFunction
end
@define_lua_struct ExpressionAggregateAgents

function ExpressionAggregateAgents(e1::AbstractExpression, aggregate_function::AggregateFunction, label::String)
    @if_expression_has_no_data_return_null e1

    @debug "AGGREGATE AGENTS: $(e1.attributes)"

    attributes = copy(e1.attributes)

    attributes.labels = if has_data(e1)
        String[label]
    else
        String[]
    end

    @debug "AGGREGATE AGENTS= $attributes"

    return ExpressionAggregateAgents(
        attributes,
        e1,
        aggregate_function,
    )
end

function aggregate_agents(x::AbstractExpression, aggregate_function::AggregateFunction, label::String)
    return ExpressionAggregateAgents(x, aggregate_function, label)
end
@define_lua_function aggregate_agents

function evaluate(e::ExpressionAggregateAgents; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e1; kwargs...)

    if e.aggregate_function.type == AggregateType.Sum
        return [sum(data)]
    elseif e.aggregate_function.type == AggregateType.Average
        return [mean(data)]
    elseif e.aggregate_function.type == AggregateType.Min
        return [minimum(data)]
    elseif e.aggregate_function.type == AggregateType.Max
        return [maximum(data)]
    elseif e.aggregate_function.type == AggregateType.Percentile
        return [quantile(data, e.aggregate_function.parameter)]
    else
        error("Aggregate function $(e.aggregate_function) not implemented yet.")
    end
end
