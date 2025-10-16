mutable struct ExpressionConcatenateAgents <: AbstractVariadic
    attributes::Attributes
    expressions::Vector{AbstractExpression}
end
@define_lua_struct ExpressionConcatenateAgents

function ExpressionConcatenateAgents(expressions::Vector{<:AbstractExpression})
    filtered_expressions = [e for e in expressions if has_data(e)]
    if length(filtered_expressions) == 0
        return ExpressionNull()
    end

    for e in filtered_expressions
        @debug "CONCATENATE AGENTS: $(e.attributes)"
    end

    attributes = copy(filtered_expressions[1].attributes)
    attributes.labels = [attr for expression in filtered_expressions for attr in expression.attributes.labels]

    @debug "CONCATENATE AGENTS= $attributes"

    return ExpressionConcatenateAgents(attributes, filtered_expressions)
end

function concatenate_agents(x::AbstractExpression...)
    return ExpressionConcatenateAgents([x...])
end
@define_lua_function concatenate_agents

function evaluate(e::ExpressionConcatenateAgents; kwargs...)
    return vcat([evaluate(expr; kwargs...) for expr in e.expressions]...)
end
