mutable struct ExpressionUnary{F <: Function} <: Expression
    attributes::Attributes
    e::Expression
    f::F

    function ExpressionUnary(e::Expression, f::F) where {F <: Function}
        attributes = copy(e.attributes)
        return new{F}(attributes, e, f)
    end
end
@define_lua_struct ExpressionUnary

Base.:-(x::Expression) = ExpressionUnary(x, Base.:−)
neg(x) = Base.:-(x)
@define_lua_function neg