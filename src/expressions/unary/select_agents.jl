mutable struct ExpressionSelectAgents <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    indices::Vector{Int}

    function ExpressionSelectAgents(e1::AbstractExpression, indices::Vector)
        @debug "SELECT AGENTS: $(e1.attributes)"

        attributes = copy(e1.attributes)

        attributes.labels = attributes.labels[indices]

        @debug "SELECT AGENTS= $attributes"

        return new(attributes, e1, indices)
    end
end
@define_lua_struct ExpressionSelectAgents

function select_agents(x::AbstractExpression, indices::Vector)
    return ExpressionSelectAgents(x, Int.(indices))
end
@define_lua_function select_agents

function evaluate(e::ExpressionSelectAgents; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e1; kwargs...)
    return data[e.indices]
end
