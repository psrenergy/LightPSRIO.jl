mutable struct ExpressionDataQuiver <: AbstractExpression
    path::String
    filename::String
    attributes::Attributes
    reader::Optional{Quiver.Reader}
end

function ExpressionDataQuiver(path::String, filename::String)
    try
        reader = Quiver.Reader{Quiver.binary}(joinpath(path, filename))
        attributes = Attributes(reader)
        @info("Loading $filename ($attributes)")
        Quiver.close!(reader)
        return ExpressionDataQuiver(path, filename, attributes, nothing)
    catch ArgumentError
        @info("The output $filename has no data")
        return ExpressionNull()
    end
end

@define_lua_struct ExpressionDataQuiver

function start!(e::ExpressionDataQuiver)
    if has_data(e)
        e.reader = Quiver.Reader{Quiver.binary}(joinpath(e.path, e.filename))
    end
    return nothing
end

function evaluate(e::ExpressionDataQuiver; kwargs...)
    if has_data(e)
        # Get minimum between dimension_size and kwargs
        constrained_values = []
        for (key, value) in pairs(kwargs)
            dimension_index = findfirst(==(key), e.attributes.dimensions)
            if dimension_index !== nothing
                max_size = e.attributes.dimension_size[dimension_index]
                push!(constrained_values, key => min(value, max_size))
            else
                push!(constrained_values, key => value)
            end
        end
        constrained_kwargs = pairs(NamedTuple(constrained_values))
        return Quiver.goto!(e.reader; constrained_kwargs...)
    else
        return Float64[]
    end
end

function finish!(e::ExpressionDataQuiver)
    if has_data(e) && !isnothing(e.reader)
        Quiver.close!(e.reader)
        e.reader = nothing
    end
    return nothing
end
