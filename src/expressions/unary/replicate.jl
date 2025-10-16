function replicate(e1::AbstractExpression, dimension::String, times::Number)
    return ExpressionConcatenate(dimension, fill(e1, Int(times)))
end
@define_lua_function replicate
