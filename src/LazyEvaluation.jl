module LazyEvaluation

abstract type Expression end

abstract type ExpressionData <: Expression end

Base.promote_rule(::Type{ExpressionData}, ::Type{ExpressionData}) = ExpressionData

mutable struct ExpressionDataNumber{T <: Number} <: ExpressionData
    value::T
    function ExpressionDataNumber(x::T) where {T <: Number}
        return new{T}(x)
    end
end

Base.show(io::IO, e::ExpressionDataNumber) = show(io, "$(e.value)")

function evaluate(e::ExpressionDataNumber)
    return e.value
end

struct ExpressionBinary{Operator <: Function} <: Expression
    left::Expression
    right::Expression
    operator::Operator
end

Base.promote_rule(::Type{ExpressionData}, ::Type{ExpressionBinary}) = ExpressionBinary
Base.promote_rule(::Type{ExpressionBinary}, ::Type{ExpressionData}) = ExpressionBinary
Base.promote_rule(::Type{ExpressionBinary}, ::Type{ExpressionBinary}) = ExpressionBinary

Base.:+(e1::Expression, e2::Expression) = ExpressionBinary(e1, e2, +)
Base.:*(e1::Expression, e2::Expression) = ExpressionBinary(e1, e2, *)

Base.show(io::IO, e::ExpressionBinary) = show(io, "($(e.left) $(e.operator) $(e.right))")

function evaluate(e::ExpressionBinary)
    return e.operator(evaluate(e.left), evaluate(e.right))
end

function debug5()
    a = ExpressionDataNumber(5)
    b = ExpressionDataNumber(3.0)

    e = (a + b) * b

    result = evaluate(e)
    println("The result of $e is: $result")

    return nothing
end

# function debug()
#     path1 = raw"C:\Development\PSRIO\LazyEvaluation.jl\test\demand1"
#     path2 = raw"C:\Development\PSRIO\LazyEvaluation.jl\test\demand2"

#     d1 = Quiver.Reader{Quiver.binary}(path1)
#     d2 = Quiver.Reader{Quiver.binary}(path2)

#     @show d3 = d1 + d2

#     Quiver.close!(d1)
#     Quiver.close!(d2)

#     return nothing
# end

end
