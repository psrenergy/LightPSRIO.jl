mutable struct ExpressionConvert <: AbstractUnary
    attributes::Attributes
    e::AbstractExpression

    function ExpressionConvert(e::AbstractExpression, unit::String)
        attributes = copy(e.attributes)
        @show unit
        return new(attributes, e)
    end
end
@define_lua_struct ExpressionConvert

convert(x::AbstractExpression, unit::String) = ExpressionConvert(x, unit)
@define_lua_function convert

function evaluate(e::ExpressionConvert; kwargs...)
    return evaluate(e.e; kwargs...)
end
