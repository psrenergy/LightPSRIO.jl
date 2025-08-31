mutable struct ExpressionConcatenateAgents <: AbstractVariadic
    attributes::Attributes
    expressions::Vector{AbstractExpression}

    function ExpressionConcatenateAgents(expressions::Vector{<:AbstractExpression})
        for expression in expressions
            println("CONCATENATE AGENTS: $(expression.attributes)")
        end

        attributes = copy(expressions[1].attributes)
        attributes.labels = [attr for expression in expressions for attr in expression.attributes.labels]

        println("CONCATENATE AGENTS= $attributes")

        return new(
            attributes,
            expressions,
        )
    end
end
@define_lua_struct ExpressionConcatenateAgents

function concatenate_agents(x::AbstractExpression...)
    return ExpressionConcatenateAgents([x...])
end
@define_lua_function concatenate_agents

function evaluate(e::ExpressionConcatenateAgents; kwargs...)
    return vcat([evaluate(expr; kwargs...) for expr in e.expressions]...)
end
