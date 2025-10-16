mutable struct ExpressionRenameAgents <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
end

function ExpressionRenameAgents(e1::AbstractExpression, labels::Vector)
    @if_expression_has_no_data_return_null e1

    @debug "RENAME AGENTS: $(e1.attributes)"

    attributes = copy(e1.attributes)
    attributes.labels = labels

    @debug "RENAME AGENTS= $attributes"

    return ExpressionRenameAgents(attributes, e1)
end

@define_lua_struct ExpressionRenameAgents

function rename_agents(x::AbstractExpression, labels::Vector)
    return ExpressionRenameAgents(x, String.(labels))
end
@define_lua_function rename_agents

function add_suffix(e1::AbstractExpression, suffix::String)
    @if_expression_has_no_data_return_null e1

    labels = [label * suffix for label in e1.attributes.labels]
    return rename_agents(e1, labels)
end
@define_lua_function add_suffix

function evaluate(e::ExpressionRenameAgents; kwargs...)
    return evaluate(e.e1; kwargs...)
end
