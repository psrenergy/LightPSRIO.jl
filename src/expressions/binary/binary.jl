mutable struct ExpressionBinary{F <: Function} <: AbstractBinary
    attributes::Attributes
    e1::AbstractExpression
    e2::AbstractExpression
    f::F

    function ExpressionBinary(e1::AbstractExpression, e2::AbstractExpression, f::F) where {F <: Function}
        @debug "BINARY: $(e1.attributes)"
        @debug "BINARY: $(e2.attributes)"

        a1 = e1.attributes
        a2 = e2.attributes

        labels = if a1.labels == a2.labels
            copy(a1.labels)
        elseif length(a1.labels) == 1
            copy(a2.labels)
        elseif length(a2.labels) == 1
            copy(a1.labels)
        else
            error("Labels must match for binary operations.")
        end

        dimensions = if isempty(a1.dimensions)
            copy(a2.dimensions)
        elseif isempty(a2.dimensions)
            copy(a1.dimensions)
        elseif a1.dimensions == a2.dimensions
            copy(a1.dimensions)
        else
            error("Attributes must match for binary operations.")
        end

        dimension_size = zeros(Int, length(dimensions))
        e1_dimension_size = a1.dimension_size
        e2_dimension_size = a2.dimension_size

        for (i, dimension) in enumerate(dimensions)
            e1_dimension_index = findfirst(==(dimension), a1.dimensions)
            e2_dimension_index = findfirst(==(dimension), a2.dimensions)
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

        unit = if isempty(a1.unit)
            a2.unit
        elseif isempty(a2.unit)
            a1.unit
        elseif a1.unit == a2.unit
            a1.unit
        else
            error("Units must match for binary operations ($(a1.unit) and $(a2.unit))")
        end

        attributes = Attributes(
            initial_date = a1.initial_date,
            labels = labels,
            collection = e1.attributes.collection,
            dimensions = dimensions,
            dimension_size = dimension_size,
            unit = unit,
        )

        @debug "BINARY= $attributes"

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
