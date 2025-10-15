mutable struct ExpressionRenameAgents <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression

    function ExpressionRenameAgents(e1::AbstractExpression, labels::Vector)
        if !has_data(e1)
            return ExpressionNull()
        end

        @debug "RENAME AGENTS: $(e1.attributes)"

        attributes = copy(e1.attributes)
        attributes.labels = labels

        @debug "RENAME AGENTS= $attributes"

        return new(attributes, e1)
    end
end
@define_lua_struct ExpressionRenameAgents

function rename_agents(x::AbstractExpression, labels::Vector)
    return ExpressionRenameAgents(x, String.(labels))
end
@define_lua_function rename_agents

function add_suffix(x::AbstractExpression, suffix::String)
    labels = [label * suffix for label in x.attributes.labels]
    return rename_agents(x, labels)
end
@define_lua_function add_suffix

function evaluate(e::ExpressionRenameAgents; kwargs...)
    return evaluate(e.e1; kwargs...)
end
