function repeat(e1::AbstractExpression, dimension::String, times::Integer)
    return ExpressionConcatenate(dimension, fill(e1, times))
end
@define_lua_function repeat
