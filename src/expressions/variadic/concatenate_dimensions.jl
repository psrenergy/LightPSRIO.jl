mutable struct ExpressionConcatenateDimensions <: AbstractVariadic
    attributes::Attributes
    expressions::Vector{AbstractExpression}
    dimension_symbol::Symbol

    function ExpressionConcatenateDimensions(expressions::Vector{<:AbstractExpression}, dimension::String)
        if isempty(expressions)
            error("Cannot concatenate empty list of expressions")
        end

        # Check that all expressions have data
        for expression in expressions
            if !has_data(expression)
                return ExpressionNull()
            end
        end

        dimension_symbol = Symbol(dimension)

        # Validate all expressions have compatible attributes
        first_attrs = expressions[1].attributes
        dimension_index = findfirst(==(dimension_symbol), first_attrs.dimensions)

        if dimension_index === nothing
            println("Dimension $dimension not found (dimensions: $(first_attrs.dimensions))")
            return ExpressionNull()
        end

        for (i, expression) in enumerate(expressions[2:end])
            attrs = expression.attributes

            # Check dimensions match (except for the concatenation dimension size)
            if attrs.dimensions != first_attrs.dimensions
                println("Expression $(i+1) has different dimensions: $(attrs.dimensions) vs $(first_attrs.dimensions)")
                return ExpressionNull()
            end

            # Check all dimension sizes match except the concatenation dimension
            for (dim_idx, dim) in enumerate(attrs.dimensions)
                if dim_idx != dimension_index && attrs.dimension_size[dim_idx] != first_attrs.dimension_size[dim_idx]
                    println("Expression $(i+1) has different size for dimension $dim: $(attrs.dimension_size[dim_idx]) vs $(first_attrs.dimension_size[dim_idx])")
                    return ExpressionNull()
                end
            end

            # Check labels match
            if attrs.labels != first_attrs.labels
                println("Expression $(i+1) has different labels: $(attrs.labels) vs $(first_attrs.labels)")
                return ExpressionNull()
            end

            # Check units match
            if attrs.unit != first_attrs.unit
                println("Expression $(i+1) has different unit: $(attrs.unit) vs $(first_attrs.unit)")
                return ExpressionNull()
            end
        end

        # Create output attributes
        attributes = copy(first_attrs)

        # Sum up the dimension sizes for the concatenation dimension
        total_size = sum(expr.attributes.dimension_size[dimension_index] for expr in expressions)
        attributes.dimension_size[dimension_index] = total_size

        @debug "CONCATENATE DIMENSIONS ($dimension): $(expressions[1].attributes) + ... ($(length(expressions)) expressions)"
        @debug "CONCATENATE DIMENSIONS= $attributes"

        return new(
            attributes,
            expressions,
            dimension_symbol,
        )
    end
end
@define_lua_struct ExpressionConcatenateDimensions

function concatenate_dimensions(dimension::String, x::AbstractExpression...)
    return ExpressionConcatenateDimensions([x...], dimension)
end
@define_lua_function concatenate_dimensions

function evaluate(e::ExpressionConcatenateDimensions; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    # Get the index for the requested position in the concatenation dimension
    dim_value = get(kwargs, e.dimension_symbol, 1)

    # Find which expression this index belongs to
    dimension_index = findfirst(==(e.dimension_symbol), e.attributes.dimensions)
    cumulative_size = 0

    for expression in e.expressions
        expr_size = expression.attributes.dimension_size[dimension_index]

        if dim_value <= cumulative_size + expr_size
            # This index belongs to this expression
            # Adjust the dimension value to be relative to this expression
            local_dim_value = dim_value - cumulative_size

            # Update kwargs with the local dimension value
            modified_kwargs = merge(
                NamedTuple(kwargs),
                NamedTuple{(e.dimension_symbol,)}((local_dim_value,)),
            )

            return evaluate(expression; modified_kwargs...)
        end

        cumulative_size += expr_size
    end

    # Should not reach here if dim_value is valid
    error("Invalid dimension value $dim_value for concatenated dimension $(e.dimension_symbol)")
end
