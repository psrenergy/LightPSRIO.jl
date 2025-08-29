mutable struct ExpressionConcatenateAgents <: Expression
    attributes::Attributes
    expressions::Vector{Expression}

    function ExpressionConcatenateAgents(expressions::Vector{<:Expression})
        attributes_vector = Attributes[]
        for expression in expressions
            if has_data(expression)
                println("CONCATENATE AGENTS: $(expression.attributes)")
                push!(attributes_vector, expression.attributes)
            else
                println("CONCATENATE AGENTS: null")
            end
        end

        attributes = copy(attributes_vector[1])
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
