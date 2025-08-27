function create_quiver(filename, data)
    n_agents, n_blocks, n_scenarios, n_stages = size(data)

    return Quiver.array_to_file(
        joinpath(@__DIR__, "data", filename),
        data,
        Quiver.csv;
        dimensions = ["stage", "scenario", "block"],
        labels = ["agent $i" for i in 1:n_agents],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
        unit = "",
    )

    return nothing
end

function load_quiver(filename::String)
    return Quiver.Reader{Quiver.csv}(joinpath(@__DIR__, "data", filename))
end