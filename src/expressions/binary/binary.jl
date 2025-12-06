@enumx UnitOperator begin
    Same
    Multiply
    Divide
end

mutable struct ExpressionBinary{F <: Function} <: AbstractBinary
    attributes::Attributes
    e1::AbstractExpression
    e2::AbstractExpression
    factor::Float64
    f::F

    function ExpressionBinary(e1::AbstractExpression, e2::AbstractExpression, unit_operator::UnitOperator.T, f::F) where {F <: Function}
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
            throw(ArgumentError("Labels must match for binary operations."))
        end

        dimensions = if isempty(a1.dimensions)
            copy(a2.dimensions)
        elseif isempty(a2.dimensions)
            copy(a1.dimensions)
        elseif a1.dimensions == a2.dimensions
            copy(a1.dimensions)
        else
            throw(ArgumentError("Attributes must match for binary operations."))
        end

        time_dimension = if a1.time_dimension == :none
            a2.time_dimension
        elseif a2.time_dimension == :none
            a1.time_dimension
        elseif a1.time_dimension == a2.time_dimension
            a1.time_dimension
        else
            throw(ArgumentError("Time dimensions must match for binary operations ($(a1.time_dimension) and $(a2.time_dimension))"))
        end

        frequency = if isempty(a1.frequency)
            a2.frequency
        elseif isempty(a2.frequency)
            a1.frequency
        elseif a1.frequency == a2.frequency
            a1.frequency
        else
            throw(ArgumentError("Frequencies must match for binary operations ($(a1.frequency) and $(a2.frequency))"))
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
                throw(ArgumentError("Dimensions must match or be 1 for broadcasting."))
            end
        end

        factor = 1.0
        unit = ""
        if unit_operator == UnitOperator.Same
            if a1.unit == a2.unit
                unit = a1.unit
            elseif isempty(a1.unit)
                unit = a2.unit
            elseif isempty(a2.unit)
                unit = a1.unit
            else
                try
                    factor = convert_unit(a2.unit, a1.unit)
                    unit = a1.unit
                catch
                    throw(ArgumentError("Cannot unify units '$(a1.unit)' and '$(a2.unit)'."))
                end
            end
        elseif unit_operator == UnitOperator.Multiply
            if isempty(a1.unit)
                unit = a2.unit
            elseif isempty(a2.unit)
                unit = a1.unit
            else
                unit = "($(a1.unit))*($(a2.unit))"
            end
        elseif unit_operator == UnitOperator.Divide
            if isempty(a1.unit)
                unit = "1/$(a2.unit)"
            elseif isempty(a2.unit)
                unit = a1.unit
            else
                unit = "($(a1.unit))/($(a2.unit))"
            end
        else
            throw(ArgumentError("Unknown unit operator: $(unit_operator)"))
        end

        attributes = Attributes(
            collection = e1.attributes.collection,
            dimension_size = dimension_size,
            dimensions = dimensions,
            frequency = frequency,
            initial_date = a1.initial_date,
            labels = labels,
            time_dimension = time_dimension,
            unit = unit,
        )

        @debug "BINARY= $attributes"

        return new{F}(attributes, e1, e2, factor, f)
    end
end
@define_lua_struct ExpressionBinary

Base.:+(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, UnitOperator.Same, Base.:+)
Base.:+(x::AbstractExpression, y) = Base.:+(promote(x, y)...)
Base.:+(x, y::AbstractExpression) = Base.:+(promote(x, y)...)
add(x, y) = Base.:+(x, y)
@define_lua_function add

Base.:-(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, UnitOperator.Same, Base.:−)
Base.:-(x::AbstractExpression, y) = Base.:-(promote(x, y)...)
Base.:-(x, y::AbstractExpression) = Base.:-(promote(x, y)...)
sub(x, y) = Base.:-(x, y)
@define_lua_function sub

Base.:*(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, UnitOperator.Multiply, Base.:*)
Base.:*(x::AbstractExpression, y) = Base.:*(promote(x, y)...)
Base.:*(x, y::AbstractExpression) = Base.:*(promote(x, y)...)
mul(x, y) = Base.:*(x, y)
@define_lua_function mul

Base.:/(x::AbstractExpression, y::AbstractExpression) = ExpressionBinary(x, y, UnitOperator.Divide, Base.:/)
Base.:/(x::AbstractExpression, y) = Base.:/(promote(x, y)...)
Base.:/(x, y::AbstractExpression) = Base.:/(promote(x, y)...)
div(x, y) = Base.:/(x, y)
@define_lua_function div

function evaluate(e::ExpressionBinary; kwargs...)
    return e.f.(evaluate(e.e1; kwargs...), evaluate(e.e2; kwargs...) .* e.factor)
end
