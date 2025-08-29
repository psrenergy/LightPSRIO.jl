mutable struct ExpressionAggregateAgents <: Expression
    attributes::Attributes
    e::Expression
    aggregate_function::AggregateFunction.T

    function ExpressionAggregateAgents(e::Expression, label::String, aggregate_function::AggregateFunction.T)
        println("AGGREGATE AGENTS: $(e.attributes)")

        attributes = copy(e.attributes)
        attributes.labels = [label]

        println("AGGREGATE AGENTS= $attributes")

        return new(
            attributes,
            e,
            aggregate_function,
        )
    end
end
@define_lua_struct ExpressionAggregateAgents

function aggregate_agents(x::Expression, label::String, aggregate_function::AggregateFunction.T)
    return ExpressionAggregateAgents(x, label, aggregate_function)
end
@define_lua_function aggregate_agents

function start!(e::ExpressionAggregateAgents)
    return start!(e.e)
end

function evaluate(e::ExpressionAggregateAgents; kwargs...)
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
