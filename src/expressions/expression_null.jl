struct ExpressionNull <: AbstractExpression end
@define_lua_struct ExpressionNull

function start!(::ExpressionNull)
    return nothing
end

function finish!(::ExpressionNull)
    return nothing
end