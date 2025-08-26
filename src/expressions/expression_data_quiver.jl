
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
    return Quiver.goto!(e.reader; kwargs...)
end

function finish!(e::ExpressionDataQuiver)
    Quiver.close!(e.reader)
    e.reader = nothing
    return nothing
end