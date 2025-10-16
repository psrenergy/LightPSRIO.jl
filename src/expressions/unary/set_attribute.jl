mutable struct ExpressionSetAttribute <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
end
@define_lua_struct ExpressionSetAttribute

function ExpressionSetAttribute(e1::AbstractExpression, attributes::Attributes)
    @if_expression_has_no_data_return_null e1

    @debug "SET: $(e1.attributes)"
    @debug "SET= $attributes"

    return ExpressionSetAttribute(attributes, e1)
end

function set_initial_year(e1::AbstractExpression, initial_year::Number)
    @if_expression_has_no_data_return_null e1

    attributes = copy(e1.attributes)
    set_initial_year!(attributes, Int(initial_year))

    return ExpressionSetAttribute(e1, attributes)
end
@define_lua_function set_initial_year

function evaluate(e::ExpressionSetAttribute; kwargs...)
    if !has_data(e)
        return Float64[]
    end
    return evaluate(e.e1; kwargs...)
end
