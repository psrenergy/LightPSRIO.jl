mutable struct ExpressionBinary{F <: Function} <: Expression
    attributes::Attributes
    e1::Expression
    e2::Expression
    f::F

    function ExpressionBinary(e1::Expression, e2::Expression, f::F) where {F <: Function}
        println("BINARY: $(e1.attributes)")
        println("BINARY: $(e2.attributes)")

        labels = if e1.attributes.labels == e2.attributes.labels
            copy(e1.attributes.labels)
        elseif length(e1.attributes.labels) == 1
            copy(e2.attributes.labels)
        elseif length(e2.attributes.labels) == 1
            copy(e1.attributes.labels)
        else
            error("Labels must match for binary operations.")
        end

        dimensions = if isempty(e1.attributes.dimensions)
            copy(e2.attributes.dimensions)
        elseif isempty(e2.attributes.dimensions)
            copy(e1.attributes.dimensions)
        elseif e1.attributes.dimensions == e2.attributes.dimensions
            copy(e1.attributes.dimensions)
        else
            error("Attributes must match for binary operations.")
        end

        dimension_size = zeros(Int, length(dimensions))
        e1_dimension_size = e1.attributes.dimension_size
        e2_dimension_size = e2.attributes.dimension_size

        for (i, dimension) in enumerate(dimensions)
            e1_dimension_index = findfirst(==(dimension), e1.attributes.dimensions)
            e2_dimension_index = findfirst(==(dimension), e2.attributes.dimensions)
            if e2_dimension_index === nothing || e2_dimension_size[e2_dimension_index] == 1
                dimension_size[i] = e1_dimension_size[e1_dimension_index]
            elseif e1_dimension_index === nothing || e1_dimension_size[e1_dimension_index] == 1
                dimension_size[i] = e2_dimension_size[e2_dimension_index]
            elseif e1_dimension_size[e1_dimension_index] == e2_dimension_size[e2_dimension_index]
                dimension_size[i] = e1_dimension_size[e1_dimension_index]
            else
                # dimension_size[i] = min(e1_dimension_size[e1_dimension_index], e2_dimension_size[e2_dimension_index])
                error("Dimensions must match or be 1 for broadcasting.")
            end
        end

        attributes = Attributes(labels, e1.attributes.collection, dimensions, dimension_size)

        println("BINARY= $attributes")

        return new{F}(attributes, e1, e2, f)
    end
end
@define_lua_struct ExpressionBinary

Base.:+(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:+)
Base.:+(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:+)
Base.:+(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:+)
add(x, y) = Base.:+(x, y)
@define_lua_function add

Base.:-(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:−)
Base.:-(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:−)
Base.:-(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:−)
sub(x, y) = Base.:-(x, y)
@define_lua_function sub

Base.:*(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:*)
Base.:*(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:*)
Base.:*(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:*)
mul(x, y) = Base.:*(x, y)
@define_lua_function mul

Base.:/(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:/)
Base.:/(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:/)
Base.:/(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:/)
div(x, y) = Base.:/(x, y)
@define_lua_function div

Base.:^(x::Expression, y::Expression) = ExpressionBinary(x, y, Base.:^)
Base.:^(x::Expression, y) = ExpressionBinary(promote(x, y)..., Base.:^)
Base.:^(x, y::Expression) = ExpressionBinary(promote(x, y)..., Base.:^)
pow(x, y) = Base.:^(x, y)
@define_lua_function pow

# Base.show(io::IO, e::ExpressionBinary) = print(io, "($(e.e1) $(e.f) $(e.e2))")

function start!(e::ExpressionBinary)
    start!(e.e1)
    start!(e.e2)
    return nothing
end

function evaluate(e::ExpressionBinary; kwargs...)
    return e.f.(evaluate(e.e1; kwargs...), evaluate(e.e2; kwargs...))
end

function finish!(e::ExpressionBinary)
    finish!(e.e1)
    finish!(e.e2)
    return nothing
end
