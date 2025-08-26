abstract type Expression end

Base.promote_rule(::Type{<:Expression}, ::Type{<:Number}) = Expression
Base.promote_rule(::Type{<:Number}, ::Type{<:Expression}) = Expression

abstract type ExpressionData <: Expression end

mutable struct ExpressionDataNumber{T <: Number} <: ExpressionData
    attributes::Attributes
    value::T

    function ExpressionDataNumber(x::T) where {T <: Number}
        attributes = Attributes(["constant"], Collection())
        return new{T}(attributes, x)
    end
end

Base.convert(::Type{Expression}, x::Number) = ExpressionDataNumber(x)

Base.show(io::IO, e::ExpressionDataNumber) = print(io, "$(e.value)")

start!(::ExpressionDataNumber) = nothing

evaluate(e::ExpressionDataNumber; kwargs...) = e.value

finish!(::ExpressionDataNumber) = nothing

###################################################################################################

mutable struct ExpressionUnary{F <: Function} <: Expression
    attributes::Attributes
    e::Expression
    f::F

    function ExpressionUnary(e::Expression, f::F) where {F <: Function}
        attributes = copy(e.attributes)
        return new{F}(attributes, e, f)
    end
end
@define_lua_struct ExpressionUnary

Base.:-(x::Expression) = ExpressionUnary(x, Base.:−)
neg(x) = Base.:-(x)
@define_lua_function neg

###################################################################################################

mutable struct ExpressionBinary{F <: Function} <: Expression
    attributes::Attributes
    e1::Expression
    e2::Expression
    f::F

    function ExpressionBinary(e1::Expression, e2::Expression, f::F) where {F <: Function}
        labels = e1.attributes.labels

        dimensions = if isempty(e1.attributes.dimensions)
            copy(e2.attributes.dimensions)
        elseif isempty(e2.attributes.dimensions)
            copy(e1.attributes.dimensions)
        elseif e1.attributes.dimensions == e2.attributes.dimensions
            copy(e1.attributes.dimensions)
        else
            error("Attributes must match for binary operations.")
        end

        dimension_size = e1.attributes.dimension_size

        attributes = Attributes(labels, e1.attributes.collection, dimensions, dimension_size)

        return new{F}(attributes, e1, e2, f)
    end
end
@define_lua_struct ExpressionBinary

Base.:+(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:+)
Base.:+(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:+)
Base.:+(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:+)
add(x, y) = Base.:+(x, y)
@define_lua_function add

Base.:-(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:−)
Base.:-(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:−)
Base.:-(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:−)
sub(x, y) = Base.:-(x, y)
@define_lua_function sub

Base.:*(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:*)
Base.:*(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:*)
Base.:*(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:*)
mul(x, y) = Base.:*(x, y)
@define_lua_function mul

Base.:/(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:/)
Base.:/(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:/)
Base.:/(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:/)
div(x, y) = Base.:/(x, y)
@define_lua_function div

# Base.show(io::IO, e::ExpressionBinary) = print(io, "($(e.e1) $(e.f) $(e.e2))")

function start!(e::ExpressionBinary)
    start!(e.e1)
    return start!(e.e2)
end

function evaluate(e::ExpressionBinary; kwargs...)
    return e.f.(evaluate(e.e1; kwargs...), evaluate(e.e2; kwargs...))
end

function finish!(e::ExpressionBinary)
    finish!(e.e1)
    return finish!(e.e2)
end

###################################################################################################

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

###################################################################################################

mutable struct Generic
    case_index::Int
end
function Generic()
    return Generic(1)
end
@define_lua_struct Generic

function load(generic::Generic, filename::String)
    path = cases[generic.case_index]
    return ExpressionDataQuiver(path, filename)
end
@define_lua_function load

function save(e::Expression, filename::String)
    println("Saving expression data to $filename")

    attributes = e.attributes
    labels = attributes.labels
    dimensions = attributes.dimensions
    dimension_size = attributes.dimension_size

    path = raw"C:\Development\PSRIO\LightPSRIO.jl\test"

    writer = Quiver.Writer{Quiver.csv}(
        joinpath(path, filename);
        labels = labels,
        dimensions = string.(dimensions),
        time_dimension = "stage",
        dimension_size = dimension_size,
        # initial_date = metadata.initial_date,
        # unit = metadata.unit,
        # frequency = metadata.frequency,
    )

    start!(e)
    for indices in Iterators.product([1:size for size in dimension_size]...)
        kwargs = NamedTuple{Tuple(dimensions)}(indices)
        result = evaluate(e; kwargs...)
        println("The result for $kwargs is: $result")

        Quiver.write!(writer, result; kwargs...)
    end
    finish!(e)

    Quiver.close!(writer)

    return nothing
end
@define_lua_function save


