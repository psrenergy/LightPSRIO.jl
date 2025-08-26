
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
