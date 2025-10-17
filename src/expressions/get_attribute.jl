function get_years(e::AbstractExpression)
    if e isa ExpressionNull
        return 0
    end
    return get_years(e.attributes)
end
@define_lua_function get_years
