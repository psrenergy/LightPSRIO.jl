mutable struct ExpressionConcatenateAgents <: Expression
    attributes::Attributes
    expressions::Vector{Expression}

    function ExpressionConcatenateAgents(expressions::Vector{<:Expression})
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

function concatenate_agents(x::Expression...)
    return ExpressionConcatenateAgents([x...])
end
@define_lua_function concatenate_agents

function start!(e::ExpressionConcatenateAgents)
    for expression in e.expressions
        start!(expression)
    end
    return nothing
end

function evaluate(e::ExpressionConcatenateAgents; kwargs...)
    return vcat([evaluate(expr; kwargs...) for expr in e.expressions]...)
end

function finish!(e::ExpressionConcatenateAgents)
    for expression in e.expressions
        finish!(expression)
    end
    return nothing
end
