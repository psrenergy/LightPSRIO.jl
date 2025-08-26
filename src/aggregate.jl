
mutable struct ExpressionAggregation <: Expression
    attributes::Attributes
    e::Expression

    function ExpressionAggregation(e::Expression, dimension::String)
        attributes = copy(e.attributes)

        dimension_index = findfirst(==(dimension), attributes.dimensions)
        if dimension_index === nothing
            error("Dimension $dimension not found.")
        end
        attributes.dimension_size[dimension_index] = 1

        return new{F}(attributes, e)
    end
end
@define_lua_struct ExpressionAggregation

function aggregate(x::Expression, dimension::String)
    return ExpressionAggregation(x, dimension)
end
@define_lua_function aggregate

function start!(e::ExpressionAggregation)
    start!(e.e)
end

function evaluate(e::ExpressionAggregation; kwargs...)
    
end

function finish!(e::ExpressionAggregation)
    finish!(e.e)
end
