module LightPSRIO

using LuaNova
using Quiver

###################################################################################################

struct Attributes 
    dimensions::Vector{Symbol}
end

###################################################################################################

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

###################################################################################################

mutable struct ExpressionUnary{F <: Function} <: Expression
    attributes::Attributes
    e::Expression
    f::F

    function ExpressionUnary(e::Expression, f::F) where {F <: Function}
        attributes = copy(e.attributes)
        return new{F}(attributes, e, f)
    end
end

Base.:-(x::Expression) = ExpressionUnary(x, Base.:−)

###################################################################################################

mutable struct ExpressionBinary{F <: Function} <: Expression
    attributes::Attributes
    e1::Expression
    e2::Expression
    f::F

    function ExpressionBinary(e1::Expression, e2::Expression, f::F) where {F <: Function}
        @assert e1.attributes == e2.attributes "Attributes must match for binary operations."
        attributes = copy(e1.attributes)
        return new{F}(attributes, e1, e2, f)
    end
end

Base.:+(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:+)
Base.:+(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:+)
Base.:+(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:+)

Base.:-(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:−)
Base.:-(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:−)
Base.:-(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:−)

Base.:*(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:*)
Base.:*(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:*)
Base.:*(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:*)

Base.:/(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:/)
Base.:/(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:/)
Base.:/(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:/)

Base.show(io::IO, e::ExpressionBinary) = print(io, "($(e.left) $(e.operator) $(e.right))")

function evaluate(e::ExpressionBinary; kwargs...)
    return e.f.(evaluate(e.e1; kwargs...), evaluate(e.e2; kwargs...))
end

function build_lazy_expression_tree(e::Any)
    if e isa Number
        return :(ExpressionDataNumber($e))
    end

    # Recursive Step: If it's a function call (like `a + b`), process each argument recursively.
    if e isa Expr && e.head == :call
        # e.args[1] is the operator (e.g., :+)
        # e.args[2:end] are the arguments
        op = e.args[1]
        processed_args = [build_lazy_expression_tree(arg) for arg in e.args[2:end]]
        return :($op($(processed_args...)))
    end

    return e
end

macro lazy_expression(ex)
    return esc(build_lazy_expression_tree(ex))
end

###################################################################################################

mutable struct ExpressionDataQuiver <: ExpressionData
    reader::Quiver.Reader

    function ExpressionDataQuiver()
        path = raw"C:\Development\PSRIO\LightPSRIO.jl\test\demand1"
        reader = Quiver.Reader{Quiver.csv}(path)
        return new(reader)
    end
end

function close!(e::ExpressionDataQuiver)
    Quiver.close!(e.reader)
    return nothing
end

function evaluate(e::ExpressionDataQuiver; kwargs...)
    return Quiver.goto!(e.reader; kwargs...)
end

###################################################################################################

@define_lua_struct ExpressionDataQuiver
@define_lua_struct ExpressionBinary

mutable struct System end
@define_lua_struct System

function load(::System)
    return ExpressionDataQuiver()
end
@define_lua_function load

function save(e::Expression)
    println("Saving expression data...")
    result = evaluate(e; stage = 1, scenario = 1)
    println("The result is: $result")
    return nothing
end
@define_lua_function save

function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

add(x, y) = Base.:+(x, y)
@define_lua_function add

####################################################################################

function debug()
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(
        L, System,
        "load", load,
    )

    @push_lua_struct(
        L, ExpressionDataQuiver,
        "__add", add,
        "save", save,
    )

    @push_lua_struct(
        L, ExpressionBinary,
        "__add", add,
        "save", save,
    )

    LuaNova.safe_script(
        L, """
    system = System()
    e1 = system:load()
    e2 = system:load()
    e3 = e1 + e2 + 1
    e3:save()
    -- julia_typeof(exp)
    """,
    )

    return LuaNova.close(L)
end

function debug5()
    b = ExpressionDataNumber(3.0)
    e = (5 + b) * b + 2
    result = evaluate(e)
    println("The result of $e is: $result")

    e = @lazy_expression (5 + 3.0) * 3.0 + 2
    result = evaluate(e)
    println("The result of $e is: $result")

    d1 = ExpressionDataQuiver()
    d2 = ExpressionDataQuiver()

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
