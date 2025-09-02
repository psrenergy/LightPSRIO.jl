mutable struct ExpressionAggregateAgents <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    aggregate_function::AggregateFunction.T

    function ExpressionAggregateAgents(e1::AbstractExpression, aggregate_function::AggregateFunction.T, label::String)
        @debug "AGGREGATE AGENTS: $(e1.attributes)"

        attributes = copy(e1.attributes)

        attributes.labels = if has_data(e1)
            String[label]
        else
            String[]
        end

        @debug "AGGREGATE AGENTS= $attributes"

        return new(
            attributes,
            e1,
            aggregate_function,
        )
    end
end
@define_lua_struct ExpressionAggregateAgents

function aggregate_agents(x::AbstractExpression, aggregate_function::AggregateFunction.T, label::String)
    return ExpressionAggregateAgents(x, aggregate_function, label)
end
@define_lua_function aggregate_agents

function evaluate(e::ExpressionAggregateAgents; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e1; kwargs...)

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
