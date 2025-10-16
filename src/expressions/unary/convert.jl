mutable struct ExpressionConvert <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
end
@define_lua_struct ExpressionConvert

function ExpressionConvert(e1::AbstractExpression, unit::String)
    @if_expression_has_no_data_return_null e1

    attributes = copy(e1.attributes)
    return ExpressionConvert(attributes, e1)
end


convert(x::AbstractExpression, unit::String) = ExpressionConvert(x, unit)
@define_lua_function convert

function evaluate(e::ExpressionConvert; kwargs...)
    return evaluate(e.e1; kwargs...)
end
