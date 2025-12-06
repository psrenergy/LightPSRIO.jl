mutable struct ExpressionConvert <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    factor::Float64
end
@define_lua_struct ExpressionConvert

function ExpressionConvert(e1::AbstractExpression, unit::String)
    @if_expression_has_no_data_return_null e1

    @debug "CONVERT: $(e1.attributes)"

    factor = try
        convert_unit(e1.attributes.unit, unit)
    catch e
        throw(ArgumentError("Cannot convert from unit '$(e1.attributes.unit)' to unit '$(unit)'."))
    end

    attributes = copy(e1.attributes)
    attributes.unit = unit

    @debug "CONVERT= $attributes with factor $factor"

    return ExpressionConvert(attributes, e1, factor)
end

function convert(e1::AbstractExpression, unit::String)
    return ExpressionConvert(e1, unit)
end
@define_lua_function convert

function evaluate(e::ExpressionConvert; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    data = evaluate(e.e1; kwargs...)
    return data .* e.factor
end
