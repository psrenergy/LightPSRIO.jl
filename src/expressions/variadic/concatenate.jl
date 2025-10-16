mutable struct ExpressionConcatenate <: AbstractVariadic
    attributes::Attributes
    expressions::Vector{AbstractExpression}
    dimension::Symbol

    function ExpressionConcatenate(dimension::String, expressions::Vector{<:AbstractExpression})
        dimension_symbol = Symbol(dimension)

        for expression in expressions
            @debug "CONCATENATE: $(expression.attributes)"
        end

        attributes = copy(expressions[1].attributes)

        # Find the index of the dimension to concatenate
        dim_index = findfirst(==(dimension_symbol), attributes.dimensions)
        if dim_index === nothing
            error("Dimension '$dimension' not found in expression attributes")
        end

        # Update the size of the concatenated dimension
        attributes.dimension_size[dim_index] =
            sum(expr.attributes.dimension_size[dim_index] for expr in expressions)

        @debug "CONCATENATE= $attributes"

        return new(
            attributes,
            expressions,
            dimension_symbol,
        )
    end
end
@define_lua_struct ExpressionConcatenate

function concatenate(dimension::String, x::AbstractExpression...)
    return ExpressionConcatenate(dimension, [x...])
end
@define_lua_function concatenate

function evaluate(e::ExpressionConcatenate; kwargs...)
    # Find the index of the dimension to concatenate
    dim_index = findfirst(==(e.dimension), e.attributes.dimensions)

    # Get the dimension value from kwargs
    dim_value = get(kwargs, e.dimension, 1)

    # Find which expression contains this index
    cumulative_size = 0
    for expression in e.expressions
        expr_dim_size = expression.attributes.dimension_size[dim_index]
        if dim_value <= cumulative_size + expr_dim_size
            # Adjust the dimension value for this expression
            adjusted_value = dim_value - cumulative_size
            adjusted_kwargs = merge(kwargs, NamedTuple{(e.dimension,)}((adjusted_value,)))
            return evaluate(expression; adjusted_kwargs...)
        end
        cumulative_size += expr_dim_size
    end

    return error("Dimension value $dim_value out of bounds for concatenated dimension $(e.dimension)")
end
