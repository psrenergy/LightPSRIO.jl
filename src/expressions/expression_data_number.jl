
mutable struct ExpressionDataNumber{T <: Number} <: ExpressionData
    attributes::Attributes
    value::T

    function ExpressionDataNumber(x::T) where {T <: Number}
        attributes = Attributes(["constant"], Collection())
        return new{T}(attributes, x)
    end
end

Base.convert(::Type{Expression}, x::Number) = ExpressionDataNumber(x)

Base.show(io::IO, e::ExpressionDataNumber) = print(io, "$(e.value)")

start!(::ExpressionDataNumber) = nothing

evaluate(e::ExpressionDataNumber; kwargs...) = e.value

finish!(::ExpressionDataNumber) = nothing