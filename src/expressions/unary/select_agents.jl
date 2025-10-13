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

function select_agents(x::AbstractExpression, vector::Vector)
    indices = Int[]
    labels = x.attributes.labels

    for item in vector
        if isa(item, String)
            index = findfirst(==(item), labels)
            if index === nothing
                throw(ArgumentError("Label '$item' not found in expression labels: $(labels)"))
            end
            push!(indices, index)
        elseif isa(item, Number)
            index = Int(item)
            push!(indices, index)
        else
            throw(ArgumentError("Invalid item type: $(typeof(item)). Must be String or Number."))
        end
    end
    return ExpressionSelectAgents(x, indices)
end
@define_lua_function select_agents

function evaluate(e::ExpressionSelectAgents; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e1; kwargs...)
    return data[e.indices]
end
