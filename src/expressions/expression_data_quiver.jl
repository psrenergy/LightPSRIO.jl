
mutable struct ExpressionDataQuiver <: ExpressionData
    path::String
    filename::String
    attributes::Attributes
    reader::Optional{Quiver.Reader}

    function ExpressionDataQuiver(path::String, filename::String)
        reader = Quiver.Reader{Quiver.csv}(joinpath(path, filename))
        attributes = Attributes(reader)
        return new(path, filename, attributes, nothing)
    end
end
@define_lua_struct ExpressionDataQuiver

function start!(e::ExpressionDataQuiver)
    e.reader = Quiver.Reader{Quiver.csv}(joinpath(e.path, e.filename))
    return nothing
end

function evaluate(e::ExpressionDataQuiver; kwargs...)
    # Get minimum between dimension_size and kwargs
    constrained_kwargs = Dict{Symbol, Int}()
    for (key, value) in pairs(kwargs)
        dim_index = findfirst(==(key), e.attributes.dimensions)
        if dim_index !== nothing
            max_size = e.attributes.dimension_size[dim_index]
            constrained_kwargs[key] = min(value, max_size)
        else
            constrained_kwargs[key] = value
        end
    end

    return Quiver.goto!(e.reader; constrained_kwargs...)
end

function finish!(e::ExpressionDataQuiver)
    if !isnothing(e.reader)
        Quiver.close!(e.reader)
        e.reader = nothing
    end
    return nothing
end
