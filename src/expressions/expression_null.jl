struct ExpressionNull <: AbstractExpression end
@define_lua_struct ExpressionNull

function start!(::ExpressionNull)
    return nothing
end

function finish!(::ExpressionNull)
    return nothing
end

macro if_expression_has_no_data_return_null(expr)
    return quote
        if !has_data($(esc(expr)))
            @debug "Expression has no data"
            return ExpressionNull()
        end
    end
end
