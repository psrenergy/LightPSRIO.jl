function create_quiver(filename; n_stages::Integer, n_blocks::Integer, n_scenarios::Integer, constant::Float64)
    writer = Quiver.Writer{Quiver.csv}(
        joinpath(@__DIR__, "data", filename);
        dimensions = ["stage", "scenario", "block"],
        labels = ["stage", "scenario", "block", "constant"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
    )

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            for block in 1:n_blocks
                data = Float64[stage, scenario, block, constant]
                Quiver.write!(writer, data; stage, scenario, block)
            end
        end
    end

    Quiver.close!(writer)

    return nothing
end

function load_quiver(filename::String)
    return Quiver.Reader{Quiver.csv}(joinpath(@__DIR__, "data", filename))
end
