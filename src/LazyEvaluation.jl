module LazyEvaluation

using Quiver

abstract type Expression end

Base.promote_rule(::Type{<:Expression}, ::Type{<:Number}) = Expression
Base.promote_rule(::Type{<:Number}, ::Type{<:Expression}) = Expression

abstract type ExpressionData <: Expression end

mutable struct ExpressionDataNumber{T <: Number} <: ExpressionData
    value::T
    function ExpressionDataNumber(x::T) where {T <: Number}
        return new{T}(x)
    end
end

Base.convert(::Type{Expression}, x::Number) = ExpressionDataNumber(x)

Base.show(io::IO, e::ExpressionDataNumber) = print(io, "$(e.value)")

function evaluate(e::ExpressionDataNumber; kwargs...)
    return e.value
end

struct ExpressionBinary{Operator <: Function} <: Expression
    left::Expression
    right::Expression
    operator::Operator
end

Base.:+(x::Expression, y::Expression) = ExpressionBinary(x, y, +)
Base.:+(x::Expression, y) = ExpressionBinary(promote(x, y)..., +)
Base.:+(x, y::Expression) = ExpressionBinary(promote(x, y)..., +)

Base.:*(x::Expression, y::Expression) = ExpressionBinary(x, y, *)
Base.:*(x::Expression, y) = ExpressionBinary(promote(x, y)..., *)
Base.:*(x, y::Expression) = ExpressionBinary(promote(x, y)..., *)

Base.show(io::IO, e::ExpressionBinary) = print(io, "($(e.left) $(e.operator) $(e.right))")

function evaluate(e::ExpressionBinary; kwargs...)
    return e.operator.(evaluate(e.left; kwargs...), evaluate(e.right; kwargs...))
end

###################################################################################################

mutable struct ExpressionDataQuiver <: ExpressionData
    reader::Quiver.Reader

    function ExpressionDataQuiver(path::AbstractString)
        reader = Quiver.Reader{Quiver.csv}(path)
        return new(reader)
    end
end

function close!(e::ExpressionDataQuiver)
    Quiver.close!(e.reader)
    return nothing
end

function evaluate(e::ExpressionDataQuiver; kwargs...)
    stage = kwargs[:stage]
    scenario = kwargs[:scenario]
    return Quiver.goto!(e.reader, stage = stage, scenario = scenario)
end

function debug5()
    b = ExpressionDataNumber(3.0)
    e = (5 + b) * b + 2

    result = evaluate(e)
    println("The result of $e is: $result")

    d1 = ExpressionDataQuiver(raw"C:\Development\PSRIO\LightPSRIO.jl\test\demand1")
    d2 = ExpressionDataQuiver(raw"C:\Development\PSRIO\LightPSRIO.jl\test\demand2")

    e = d1 + d2 + 1

    for stage in 1:12
            result = evaluate(e; stage = stage, scenario = 1)
            println("The result of stage $stage is: $result")
    end

    close!(d1)
    close!(d2)

    return nothing
end

end
