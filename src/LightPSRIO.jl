module LightPSRIO

using LuaNova
using Quiver

abstract type Expression end

abstract type ExpressionData <: Expression end

mutable struct ExpressionDataNumber{T <: Number} <: ExpressionData
    value::T
    function ExpressionDataNumber(x::T) where {T <: Number}
        return new{T}(x)
    end
end

struct ExpressionBinary <: Expression
    left::Expression
    right::Expression
    op::Symbol
end

Base.:+(e1::Expression, e2::Expression) = ExpressionBinary(e1, e2, :+)
Base.:*(e1::Expression, e2::Expression) = ExpressionBinary(e1, e2, :*)

Base.promote_rule(::Type{ExpressionData}, ::Type{ExpressionBinary}) = ExpressionBinary
Base.promote_rule(::Type{ExpressionBinary}, ::Type{ExpressionData}) = ExpressionBinary
Base.promote_rule(::Type{ExpressionData}, ::Type{ExpressionData}) = ExpressionData
Base.promote_rule(::Type{ExpressionBinary}, ::Type{ExpressionBinary}) = ExpressionBinary

function evaluate(e::ExpressionData)
    return e.value
end

function evaluate(e::ExpressionBinary)
    left_val = evaluate(e.left)
    right_val = evaluate(e.right)

    if e.op == :+
        return left_val + right_val
    elseif e.op == :*
        return left_val * right_val
    elseif e.op == :-
        return left_val - right_val
    elseif e.op == :/
        return left_val / right_val
    else
        throw(ArgumentError("Unsupported operator: $(e.op)"))
    end
end

function debug5()
    a = ExpressionDataLiteral(5)
    b = ExpressionDataLiteral(3)

    e = (a + b) * b

    result = evaluate(e)
    println("The result of (5 + 3) * 3 is: $result")

    return nothing
end

# function debug()
#     path1 = raw"C:\Development\PSRIO\LightPSRIO.jl\test\demand1"
#     path2 = raw"C:\Development\PSRIO\LightPSRIO.jl\test\demand2"

#     d1 = Quiver.Reader{Quiver.binary}(path1)
#     d2 = Quiver.Reader{Quiver.binary}(path2)

#     @show d3 = d1 + d2

#     Quiver.close!(d1)
#     Quiver.close!(d2)

#     return nothing
# end

end
