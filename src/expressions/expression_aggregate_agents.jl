mutable struct ExpressionAggregateAgents <: AbstractExpression
    attributes::Attributes
    e::AbstractExpression
    aggregate_function::AggregateFunction.T

    function ExpressionAggregateAgents(e::AbstractExpression, aggregate_function::AggregateFunction.T, label::String)
        println("AGGREGATE AGENTS: $(e.attributes)")

        attributes = copy(e.attributes)

        attributes.labels = if has_data(e)
            String[label]
        else
            String[]
        end

        println("AGGREGATE AGENTS= $attributes")

        return new(
            attributes,
            e,
            aggregate_function,
        )
    end
end
@define_lua_struct ExpressionAggregateAgents

function aggregate_agents(x::AbstractExpression, aggregate_function::AggregateFunction.T, label::String)
    return ExpressionAggregateAgents(x, aggregate_function, label)
end
@define_lua_function aggregate_agents

function start!(e::ExpressionAggregateAgents)
    return start!(e.e)
end

function evaluate(e::ExpressionAggregateAgents; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e; kwargs...)

    if e.aggregate_function == AggregateFunction.Sum
        return [sum(data)]
    elseif e.aggregate_function == AggregateFunction.Average
        return [mean(data)]
    elseif e.aggregate_function == AggregateFunction.Min
        return [minimum(data)]
    elseif e.aggregate_function == AggregateFunction.Max
        return [maximum(data)]
    else
        error("Aggregate function $(e.aggregate_function) not implemented yet.")
    end
end

function finish!(e::ExpressionAggregateAgents)
    return finish!(e.e)
end
