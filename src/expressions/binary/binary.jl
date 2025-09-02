mutable struct ExpressionBinary{F <: Function} <: AbstractBinary
    attributes::Attributes
    e1::AbstractExpression
    e2::AbstractExpression
    f::F

    function ExpressionBinary(e1::AbstractExpression, e2::AbstractExpression, f::F) where {F <: Function}
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

        if a1.unit != a2.unit
            error("Units must match for binary operations.")
        end

        attributes = Attributes(labels, e1.attributes.collection, dimensions, dimension_size, a1.unit)

        println("BINARY= $attributes")

        return new{F}(attributes, e1, e2, f)
    end
end
@define_lua_struct ExpressionBinary

Base.:+(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, Base.:+)
Base.:+(x::AbstractExpression, y) = ExpressionBinary(promote(x, y)..., Base.:+)
Base.:+(x, y::AbstractExpression) = ExpressionBinary(promote(x, y)..., Base.:+)
add(x, y) = Base.:+(x, y)
@define_lua_function add

Base.:-(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, Base.:−)
Base.:-(x::AbstractExpression, y) = ExpressionBinary(promote(x, y)..., Base.:−)
Base.:-(x, y::AbstractExpression) = ExpressionBinary(promote(x, y)..., Base.:−)
sub(x, y) = Base.:-(x, y)
@define_lua_function sub

Base.:*(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, Base.:*)
Base.:*(x::AbstractExpression, y) = ExpressionBinary(promote(x, y)..., Base.:*)
Base.:*(x, y::AbstractExpression) = ExpressionBinary(promote(x, y)..., Base.:*)
mul(x, y) = Base.:*(x, y)
@define_lua_function mul

Base.:/(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, Base.:/)
Base.:/(x::AbstractExpression, y) = ExpressionBinary(promote(x, y)..., Base.:/)
Base.:/(x, y::AbstractExpression) = ExpressionBinary(promote(x, y)..., Base.:/)
div(x, y) = Base.:/(x, y)
@define_lua_function div

Base.:^(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, Base.:^)
Base.:^(x::AbstractExpression, y) = ExpressionBinary(promote(x, y)..., Base.:^)
Base.:^(x, y::AbstractExpression) = ExpressionBinary(promote(x, y)..., Base.:^)
pow(x, y) = Base.:^(x, y)
@define_lua_function pow

# Base.show(io::IO, e::ExpressionBinary) = print(io, "($(e.e1) $(e.f) $(e.e2))")

function evaluate(e::ExpressionBinary; kwargs...)
    return e.f.(evaluate(e.e1; kwargs...), evaluate(e.e2; kwargs...))
end
