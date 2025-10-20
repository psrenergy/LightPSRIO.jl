function get_data_directory()
    return joinpath(@__DIR__, "data")
end

function create_quiver(filename; n_stages::Integer, n_blocks::Integer, n_scenarios::Integer, constant::Float64, frequency::String, unit::String = "")
    path = joinpath(@__DIR__, "data", filename)
    if isfile("$path.toml")
        return filename
    end

    writer = Quiver.Writer{Quiver.binary}(
        path;
        dimension_size = [n_stages, n_scenarios, n_blocks],
        dimensions = ["stage", "scenario", "block"],
        frequency = frequency,
        initial_date = DateTime(2024, 1, 1),
        labels = ["data_stage", "data_scenario", "data_block", "data_constant"],
        time_dimension = "stage",
        unit = unit,
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

    return filename
end

function remove_quiver(filename::String)
    filepath = joinpath(get_data_directory(), filename)
    for extension in [".toml", ".quiv", ".qvr",".csv"]
        if isfile(filepath * extension)
            rm(filepath * extension)
        end
    end
    return nothing
end

function open_quiver(f::Function, filename::String)
    reader = Quiver.Reader{Quiver.binary}(joinpath(get_data_directory(), filename))

    try
        f(reader)
    finally
        Quiver.close!(reader)
    end

    return nothing
end

function create_quiver_tests(filename::String)
    println("open_quiver(\"$filename\") do q")

    open_quiver(filename) do q
        println("    @test q.metadata.frequency == \"$(q.metadata.frequency)\"")
        println("    @test q.metadata.initial_date == DateTime(\"$(q.metadata.initial_date)\")")
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

function setup_tests(f::Function, filenames::String...)
    L = LightPSRIO.initialize([get_data_directory()])
    try
        return f(L)
    finally
        LightPSRIO.finalize(L)
        GC.gc()

        for filename in filenames
            remove_quiver(filename)
        end
    end
    return nothing
end
