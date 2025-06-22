module LightPSRIO

abstract type MyNumber end

struct NewFloat64 <: MyNumber
    value::Float64
end

struct NewInt32 <: MyNumber
    value::Int32
end

Base.:+(a::NewFloat64, b::NewInt32) = NewFloat64(a.value + Float64(b.value))
Base.:+(a::NewInt32, b::NewFloat64) = NewFloat64(Float64(a.value) + b.value)

Base.:+(a::NewFloat64, b::NewFloat64) = NewFloat64(a.value + b.value)

Base.:+(a::NewInt32, b::NewInt32) = NewInt32(a.value + b.value)

Base.:*(a::NewFloat64, b::NewInt32) = NewFloat64(a.value * Float64(b.value))
Base.:*(a::NewInt32, b::NewFloat64) = NewFloat64(Float64(a.value) * b.value)

Base.:*(a::NewFloat64, b::NewFloat64) = NewFloat64(a.value * b.value)

Base.:*(a::NewInt32, b::NewInt32) = NewInt32(a.value * b.value)

Base.promote_rule(::Type{NewFloat64}, ::Type{NewInt32}) = NewFloat64
Base.promote_rule(::Type{NewInt32}, ::Type{NewFloat64}) = NewFloat64
Base.promote_rule(::Type{NewFloat64}, ::Type{NewFloat64}) = NewFloat64
Base.promote_rule(::Type{NewInt32}, ::Type{NewInt32}) = NewInt32

function debug3()
    a = NewFloat64(3.5)
    b = NewInt32(2)

    c = a + b  # Should use the NewFloat64 constructor
    d = a * b  # Should use the NewFloat64 constructor

    println("Addition: $(c.value)")  # Should print: 5.5
    println("Multiplication: $(d.value)")  # Should print: 7.0

    return nothing
end

# # using LuaNova
# # using Quiver

# # using Base: convert, promote_rule, +, -, *, /, zero, one, show

# # ----------  1. Type definitions ----------
# struct Float64_reimplemented <: AbstractFloat
#     val::Float64
# end

# struct Int32_reimplemented <: Signed
#     val::Int32
# end

# # ---------- 2. Convenience constructors ----------
# Float64_reimplemented(x::Real) = Float64_reimplemented(Float64(x))
# Int32_reimplemented(x::Integer) = Int32_reimplemented(Int32(x))

# # ---------- 3. Conversion table ----------
# # a)  to our wrappers
# Base.convert(::Type{Float64_reimplemented}, x::Float64_reimplemented) = x                # already good
# Base.convert(::Type{Float64_reimplemented}, x::Real) = Float64_reimplemented(Float64(x))

# Base.convert(::Type{Int32_reimplemented}, x::Int32_reimplemented) = x
# Base.convert(::Type{Int32_reimplemented}, x::Integer) = Int32_reimplemented(Int32(x))

# # b)  back to built-ins (handy for interoperability and printing)
# Base.convert(::Type{Float64}, x::Float64_reimplemented) = x.val
# Base.convert(::Type{Int32}, x::Int32_reimplemented) = x.val

# # ---------- 4. Promotion rules ----------
# Base.promote_rule(::Type{Float64_reimplemented}, ::Type{Float64}) = Float64_reimplemented
# Base.promote_rule(::Type{Float64}, ::Type{Float64_reimplemented}) = Float64_reimplemented

# Base.promote_rule(::Type{Int32_reimplemented}, ::Type{Int32}) = Int32_reimplemented
# Base.promote_rule(::Type{Int32}, ::Type{Int32_reimplemented}) = Int32_reimplemented

# # mixed wrapper-to-wrapper → choose the wider one (float wins here)
# Base.promote_rule(::Type{Float64_reimplemented}, ::Type{Int32_reimplemented}) = Float64_reimplemented
# Base.promote_rule(::Type{Int32_reimplemented}, ::Type{Float64_reimplemented}) = Float64_reimplemented

# # ---------- 5. Zero/One (needed by generic algorithms) ----------
# zero(::Type{Float64_reimplemented}) = Float64_reimplemented(0.0)
# one(::Type{Float64_reimplemented}) = Float64_reimplemented(1.0)

# zero(::Type{Int32_reimplemented}) = Int32_reimplemented(0)
# one(::Type{Int32_reimplemented}) = Int32_reimplemented(1)

# # ---------- 6. Arithmetic kernels (single-type methods) ----------
# # Float64_reimplemented  ----------------------------------------
# Base.:+(x::Float64_reimplemented, y::Float64_reimplemented) = Float64_reimplemented(x.val + y.val)
# Base.:-(x::Float64_reimplemented, y::Float64_reimplemented) = Float64_reimplemented(x.val - y.val)
# Base.:*(x::Float64_reimplemented, y::Float64_reimplemented) = Float64_reimplemented(x.val * y.val)
# Base.:/(x::Float64_reimplemented, y::Float64_reimplemented) = Float64_reimplemented(x.val / y.val)

# # Int32_reimplemented  -----------------------------------------
# Base.:+(x::Int32_reimplemented, y::Int32_reimplemented) = Int32_reimplemented(x.val + y.val)
# Base.:-(x::Int32_reimplemented, y::Int32_reimplemented) = Int32_reimplemented(x.val - y.val)
# Base.:*(x::Int32_reimplemented, y::Int32_reimplemented) = Int32_reimplemented(x.val * y.val)
# Base.:/(x::Int32_reimplemented, y::Int32_reimplemented) = Float64_reimplemented(float(x.val) / float(y.val))  # keep / return float

# # ---------- 7. Basic pretty printing ----------
# Base.show(io::IO, x::Float64_reimplemented) = print(io, "$(x.val)_R64")
# Base.show(io::IO, x::Int32_reimplemented) = print(io, "$(x.val)_R32")

# function debug2()
#     a = Int32_reimplemented(5)
#     b = Float64_reimplemented(2.5)
#     @show a + a
#     @show b * b
#     @show a + b
#     @show (a + b) / 3

#     return nothing
# end

# abstract type Expression end

# function save(e::Expression, path::AbstractString)
#     println("Saving expression to $path")
#     return nothing
# end

# struct ExpressionData <: Expression
#     data::Quiver.Reader
# end

# struct ExpressionBinary <: Expression
#     left::Expression
#     right::Expression
#     operator::Symbol
# end

# function Base.convert(::Type{Expression}, data::Quiver.Reader)
#     return ExpressionData(data)
# end

# function Base.:+(e1::Expression, e2::Expression)
#     return ExpressionBinary(e1, e2, :+)
# end

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
