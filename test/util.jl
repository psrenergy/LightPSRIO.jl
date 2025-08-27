function create_quiver(; n_stages::Integer, n_scenarios::Integer, n_blocks::Integer)
    filename = "t$(n_stages)_s$(n_scenarios)_b$(n_blocks)"

    writer = Quiver.Writer{Quiver.csv}(
        filename;
        dimensions = ["stage", "scenario", "block"],
        labels = ["agent 1", "agent 2", "agent 3"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
    )

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            for block in 1:n_blocks
                Quiver.write!(writer, [stage, scenario, block]; stage = stage, scenario = scenario, block = block)
            end
        end
    end

    Quiver.close!(writer)

    return filename
end

function verify_quiver(filename::String; n_stages::Integer, n_scenarios::Integer, n_blocks::Integer, n_agents::Integer)
    @show reader = Quiver.Reader{Quiver.csv}(filename)

    # @assert reader.metadata.dimensions == ["stage", "scenario", "block"]

    Quiver.close!(reader)

    return nothing
end
