mutable struct ExpressionAggregateDimensions <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    aggregate_function::AggregateFunction
    dimension_symbol::Symbol
    dimension_original_size::Int
end

function ExpressionAggregateDimensions(e1::AbstractExpression, dimension::String, aggregate_function::AggregateFunction)
    @debug "AGGREGATE ($dimension): $(e1.attributes)"

    attributes = copy(e1.attributes)
    dimension_symbol = Symbol(dimension)

    dimension_index = findfirst(==(dimension_symbol), attributes.dimensions)
    if dimension_index === nothing
        println("Dimension $dimension not found (dimensions: $(attributes.dimensions))")
        return ExpressionNull()
    end
    dimension_original_size = attributes.dimension_size[dimension_index]
    attributes.dimension_size[dimension_index] = 1

    @debug "AGGREGATE ($dimension)= $attributes"

    return ExpressionAggregateDimensions(
        attributes,
        e1,
        aggregate_function,
        dimension_symbol,
        dimension_original_size,
    )
end

@define_lua_struct ExpressionAggregateDimensions

function aggregate(x::AbstractExpression, dimension::String, aggregate_function::AggregateFunction)
    return ExpressionAggregateDimensions(x, dimension, aggregate_function)
end
@define_lua_function aggregate

function evaluate(e::ExpressionAggregateDimensions; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    attributes = e.attributes
    labels_size = length(attributes.labels)
    dimension_original_size = e.dimension_original_size

    data = [zeros(labels_size) for _ in 1:dimension_original_size]

    for i in 1:dimension_original_size
        modified_kwargs = merge(
            NamedTuple(kwargs),
            NamedTuple{(e.dimension_symbol,)}((i,)),
        )

        current_value = evaluate(e.e1; modified_kwargs...)
        data[i] .= current_value
    end

    if e.aggregate_function.type == AggregateType.Sum
        return sum(data)
    elseif e.aggregate_function.type == AggregateType.Average
        return mean(data)
    elseif e.aggregate_function.type == AggregateType.Min
        return minimum(data)
    elseif e.aggregate_function.type == AggregateType.Max
        return maximum(data)
    elseif e.aggregate_function.type == AggregateType.Percentile
        return [quantile(vcat(data...), e.aggregate_function.parameter)]
    else
        error("Aggregate function $(e.aggregate_function) not implemented yet.")
    end
end
