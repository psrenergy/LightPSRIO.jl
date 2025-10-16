function get_data_directory()
    return joinpath(@__DIR__, "data")
end

function create_quiver(filename; n_stages::Integer, n_blocks::Integer, n_scenarios::Integer, constant::Float64, frequency::String, unit::String = "")
    path = joinpath(@__DIR__, "data", filename)
    if isfile("$path.toml")
        return nothing
    end

    writer = Quiver.Writer{Quiver.binary}(
        path;
        dimensions = ["stage", "scenario", "block"],
        labels = ["data_stage", "data_scenario", "data_block", "data_constant"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
        unit = unit,
        frequency = frequency,
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

function open_quiver(f::Function, filename::String)
    reader = Quiver.Reader{Quiver.binary}(joinpath(get_data_directory(), filename))
    try
        f(reader)
    finally
        Quiver.close!(reader)
    end
end

function create_quiver_tests(filename::String)
    println("open_quiver(\"$filename\") do q")

    open_quiver(filename) do q
        println("    @test q.metadata.frequency == \"$(q.metadata.frequency)\"")
        println("    # @test q.metadata.initial_date == DateTime(\"$(q.metadata.initial_date)\")")
        println("    @test q.metadata.number_of_dimensions == $(q.metadata.number_of_dimensions)")
        println("    @test q.metadata.dimensions == $(q.metadata.dimensions)")
        println("    @test q.metadata.time_dimension == :$(q.metadata.time_dimension)")
        println("    @test q.metadata.unit == \"$(q.metadata.unit)\"")
        println("    @test q.metadata.dimension_size == $(q.metadata.dimension_size)")
        println("    @test q.metadata.number_of_time_series == $(q.metadata.number_of_time_series)")
        println("    @test q.metadata.labels == $(q.metadata.labels)")
        println()

        n_stages = q.metadata.dimension_size[1]
        n_scenarios = q.metadata.dimension_size[2]
        n_blocks = q.metadata.dimension_size[3]

        for stage in 1:n_stages
            for scenario in 1:n_scenarios
                for block in 1:n_blocks
                    data = Quiver.goto!(q; stage = stage, scenario = scenario, block = block)
                    println("    @test Quiver.goto!(q; stage = $stage, scenario = $scenario, block = $block) ≈ [$(join(data, ", "))]")
                end
            end
        end
    end

    println("end\n")

    return nothing
end

function initialize_tests()
    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "GWh")
    create_quiver("input2"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month", unit = "MWh")

    create_quiver("input_month_2t_2s_2b"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, frequency = "month")
    create_quiver("input_month_36t_1s_1b"; n_stages = 36, n_scenarios = 1, n_blocks = 1, constant = 1.0, frequency = "month")

    return nothing
end

function delete_files(filenames::Vector{String})
    for filename in filenames
        filepath = joinpath(get_data_directory(), filename)
        if isfile(filepath)
            rm(filepath)
        end
    end
    return nothing
end
