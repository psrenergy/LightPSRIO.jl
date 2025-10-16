mutable struct ExpressionDataNumber{T <: Number} <: AbstractExpression
    attributes::Attributes
    value::T

    function ExpressionDataNumber(x::T) where {T <: Number}
        attributes = Attributes(
            initial_date = now(),
            labels = ["constant"],
            collection = Collection(),
            dimensions = [],
            dimension_size = [],
            unit = "",
        )
        return new{T}(attributes, x)
    end
end

Base.convert(::Type{AbstractExpression}, x::Number) = ExpressionDataNumber(x)

Base.show(io::IO, e::ExpressionDataNumber) = print(io, "$(e.value)")

start!(::ExpressionDataNumber) = nothing

evaluate(e::ExpressionDataNumber; kwargs...) = e.value

finish!(::ExpressionDataNumber) = nothing
