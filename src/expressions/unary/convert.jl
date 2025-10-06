mutable struct ExpressionConvert <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression

    function ExpressionConvert(e1::AbstractExpression, unit::String)
        attributes = copy(e1.attributes)
        return new(attributes, e1)
    end
end
@define_lua_struct ExpressionConvert

convert(x::AbstractExpression, unit::String) = ExpressionConvert(x, unit)
@define_lua_function convert

function evaluate(e::ExpressionConvert; kwargs...)
    return evaluate(e.e1; kwargs...)
end
