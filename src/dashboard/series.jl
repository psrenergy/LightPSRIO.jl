mutable struct Series
    values::Vector{Base.Pair{Int, Float64}}

    function Series()
        return new(Vector{Base.Pair{Int, Float64}}())
    end
end