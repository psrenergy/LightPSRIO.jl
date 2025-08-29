mutable struct ExpressionAggregateDimensions <: Expression
    attributes::Attributes
    e::Expression
    aggregate_function::AggregateFunction.T
    dimension_symbol::Symbol
    dimension_original_size::Int

    function ExpressionAggregateDimensions(e::Expression, dimension::String, aggregate_function::AggregateFunction.T)
        println("AGGREGATE ($dimension): $(e.attributes)")

        attributes = copy(e.attributes)
        dimension_symbol = Symbol(dimension)

        dimension_index = findfirst(==(dimension_symbol), attributes.dimensions)
        if dimension_index === nothing
            error("Dimension $dimension not found.")
        end
        dimension_original_size = attributes.dimension_size[dimension_index]
        attributes.dimension_size[dimension_index] = 1

        println("AGGREGATE ($dimension)= $attributes")

        return new(
            attributes,
            e,
            aggregate_function,
            dimension_symbol,
            dimension_original_size,
        )
    end
end
@define_lua_struct ExpressionAggregateDimensions

function aggregate(x::Expression, dimension::String, aggregate_function::AggregateFunction.T)
    return ExpressionAggregateDimensions(x, dimension, aggregate_function)
end
@define_lua_function aggregate

function start!(e::ExpressionAggregateDimensions)
    return start!(e.e)
end

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

        current_value = evaluate(e.e; modified_kwargs...)
        data[i] .= current_value
    end

    if e.aggregate_function == AggregateFunction.Sum
        return sum(data)
    elseif e.aggregate_function == AggregateFunction.Average
        return mean(data)
    elseif e.aggregate_function == AggregateFunction.Min
        return minimum(data)
    elseif e.aggregate_function == AggregateFunction.Max
        return maximum(data)
    else
        error("Aggregate function $(e.aggregate_function) not implemented yet.")
    end
end

function finish!(e::ExpressionAggregateDimensions)
    return finish!(e.e)
end
