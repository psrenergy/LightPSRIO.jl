module TestProfileDimensions

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

function create_time_series_data(filename; n_stages::Integer, n_scenarios::Integer)
    # Create data with a known pattern for testing
    # Data varies by stage to create a testable pattern
    writer = Quiver.Writer{Quiver.binary}(
        joinpath(get_data_directory(), filename);
        dimensions = ["stage", "scenario"],
        labels = ["agent1", "agent2"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios],
        initial_date = DateTime(2020, 1, 1),  # Start on a Wednesday
        unit = "MWh",
    )

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            # Create a simple pattern: value increases with stage
            # agent1 = stage, agent2 = stage * 2
            data = Float64[stage, stage * 2]
            Quiver.write!(writer, data; stage, scenario)
        end
    end

    Quiver.close!(writer)

    return nothing
end

@testset "Profile Dimensions - Daily" begin
    initialize_tests()

    # Create 14 days of data (2 full weeks) starting from Wednesday (2020-01-01)
    create_time_series_data("time_series_14days"; n_stages = 14, n_scenarios = 2)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input = generic:load("time_series_14days");

-- Profile by day of week
local daily_avg = input:profile("stage", BY_DAY(BY_AVERAGE()));
daily_avg:save("daily_avg");

local daily_sum = input:profile("stage", BY_DAY(BY_SUM()));
daily_sum:save("daily_sum");

local daily_max = input:profile("stage", BY_DAY(BY_MAX()));
daily_max:save("daily_max");
    """,
    )

    finalize(L)

    # Day 1 (Wednesday) = stages 1, 8 (average: 4.5)
    # Day 2 (Thursday) = stages 2, 9 (average: 5.5)
    # Day 3 (Friday) = stages 3, 10 (average: 6.5)
    # Day 4 (Saturday) = stages 4, 11 (average: 7.5)
    # Day 5 (Sunday) = stages 5, 12 (average: 8.5)
    # Day 6 (Monday) = stages 6, 13 (average: 9.5)
    # Day 7 (Tuesday) = stages 7, 14 (average: 10.5)

    open_quiver("daily_avg") do q
        @test q.metadata.unit == "MWh"
        @test q.metadata.dimension_size == [7, 2]

        # Check averages for each day of week across scenarios
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [4.5, 9.0]  # Wednesday avg
        @test Quiver.goto!(q; stage = 2, scenario = 1) ≈ [5.5, 11.0]  # Thursday avg
        @test Quiver.goto!(q; stage = 3, scenario = 1) ≈ [6.5, 13.0]  # Friday avg
        @test Quiver.goto!(q; stage = 4, scenario = 1) ≈ [7.5, 15.0]  # Saturday avg
        @test Quiver.goto!(q; stage = 5, scenario = 1) ≈ [8.5, 17.0]  # Sunday avg
        @test Quiver.goto!(q; stage = 6, scenario = 1) ≈ [9.5, 19.0]  # Monday avg
        @test Quiver.goto!(q; stage = 7, scenario = 1) ≈ [10.5, 21.0]  # Tuesday avg
    end

    open_quiver("daily_sum") do q
        @test q.metadata.unit == "MWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [9.0, 18.0]  # Wednesday sum
        @test Quiver.goto!(q; stage = 7, scenario = 1) ≈ [21.0, 42.0]  # Tuesday sum
    end

    open_quiver("daily_max") do q
        @test q.metadata.unit == "MWh"
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [8.0, 16.0]  # Wednesday max
        @test Quiver.goto!(q; stage = 7, scenario = 1) ≈ [14.0, 28.0]  # Tuesday max
    end

    delete_files(["time_series_14days", "daily_avg", "daily_sum", "daily_max"])

    return nothing
end

@testset "Profile Dimensions - Monthly" begin
    initialize_tests()

    # Create 365 days (1 year) of data
    create_time_series_data("time_series_365days"; n_stages = 365, n_scenarios = 1)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input = generic:load("time_series_365days");

-- Profile by month
local monthly_avg = input:profile("stage", BY_MONTH(BY_AVERAGE()));
monthly_avg:save("monthly_avg");

local monthly_min = input:profile("stage", BY_MONTH(BY_MIN()));
monthly_min:save("monthly_min");
    """,
    )

    finalize(L)

    open_quiver("monthly_avg") do q
        @test q.metadata.unit == "MWh"
        @test q.metadata.dimension_size == [12, 1]

        # January 2020 has 31 days (stages 1-31), average is 16
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [16.0, 32.0]

        # February 2020 has 29 days (stages 32-60), average is 46
        @test Quiver.goto!(q; stage = 2, scenario = 1) ≈ [46.0, 92.0]
    end

    open_quiver("monthly_min") do q
        @test q.metadata.unit == "MWh"
        # January min should be stage 1
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [1.0, 2.0]
        # February min should be stage 32
        @test Quiver.goto!(q; stage = 2, scenario = 1) ≈ [32.0, 64.0]
    end

    delete_files(["time_series_365days", "monthly_avg", "monthly_min"])

    return nothing
end

@testset "Profile Dimensions - Yearly" begin
    initialize_tests()

    # Create 730 days (2 years) of data
    create_time_series_data("time_series_730days"; n_stages = 730, n_scenarios = 2)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input = generic:load("time_series_730days");

-- Profile by year (should aggregate all to single value)
local yearly_avg = input:profile("stage", BY_YEAR(BY_AVERAGE()));
yearly_avg:save("yearly_avg");
    """,
    )

    finalize(L)

    open_quiver("yearly_avg") do q
        @test q.metadata.unit == "MWh"
        @test q.metadata.dimension_size == [1, 2]

        # Average of all 730 stages: (1 + 730) / 2 = 365.5
        @test Quiver.goto!(q; stage = 1, scenario = 1) ≈ [365.5, 731.0]
    end

    delete_files(["time_series_730days", "yearly_avg"])

    return nothing
end

@testset "Profile Dimensions - Combined with Aggregation" begin
    initialize_tests()

    create_time_series_data("time_series_30days"; n_stages = 30, n_scenarios = 3)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input = generic:load("time_series_30days");

-- Profile by day of week, then aggregate across scenarios
local daily_profile = input:profile("stage", BY_DAY(BY_AVERAGE()));
local result = daily_profile:aggregate("scenario", BY_AVERAGE());
result:save("daily_profile_scenario_avg");
    """,
    )

    finalize(L)

    open_quiver("daily_profile_scenario_avg") do q
        @test q.metadata.unit == "MWh"
        @test q.metadata.dimension_size == [7, 1]
    end

    delete_files(["time_series_30days", "daily_profile_scenario_avg"])

    return nothing
end

@testset "Profile Dimensions - Error Cases" begin
    initialize_tests()

    L = LightPSRIO.initialize([get_data_directory()])

    # Test profiling on non-stage dimension (should fail gracefully)
    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input = generic:load("input1");

-- Try to profile on scenario dimension (should print error and return null)
local result = input:profile("scenario", BY_MONTH(BY_AVERAGE()));
if result:has_data() then
    result:save("should_not_exist");
end
    """,
    )

    finalize(L)

    # Verify the error case didn't create output
    @test !isfile(joinpath(get_data_directory(), "should_not_exist"))

    return nothing
end

end
