
mutable struct ExpressionDataQuiver <: ExpressionData
    path::String
    filename::String
    attributes::Attributes
    reader::Optional{Quiver.Reader}

    function ExpressionDataQuiver(path::String, filename::String)
        reader = Quiver.Reader{Quiver.binary}(joinpath(path, filename))
        attributes = Attributes(reader)
        println("Loading $filename ($attributes)")
        Quiver.close!(reader)
        return new(path, filename, attributes, nothing)
    end
end
@define_lua_struct ExpressionDataQuiver

function start!(e::ExpressionDataQuiver)
    e.reader = Quiver.Reader{Quiver.binary}(joinpath(e.path, e.filename))
    return nothing
end

function evaluate(e::ExpressionDataQuiver; kwargs...)
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
end

function finish!(e::ExpressionDataQuiver)
    if !isnothing(e.reader)
        Quiver.close!(e.reader)
        e.reader = nothing
    end
    return nothing
end
