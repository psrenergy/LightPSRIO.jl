import Pkg
Pkg.activate(@__DIR__)

for s in 1:10
    try
        Pkg.instantiate()
        break
    catch e
        s == 10 ? rethrow(e) : sleep(s)
    end
end

using ArgParse
using PSRContinuousDeployment

function main(args::Vector{String})
    #! format: off
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--development_stage"
        nargs = '?'
        constant = "Stable release"
        default = "Stable release"
        "--version_suffix"
        nargs = '?'
        constant = ""
        default = ""
        "--overwrite"
        nargs = '?'
        constant = false        
        default = false
        eval_arg = true
        "--psrcloud"
        nargs = '?'
        constant = false
        default = false
        eval_arg = true
        "--os"
        arg_type = String
    end
    #! format: on
    parsed_args = parse_args(args, s)

    package_path = dirname(@__DIR__)

    configuration = build_configuration(;
        package_path = package_path,
        development_stage = parsed_args["development_stage"],
        version_suffix = parsed_args["version_suffix"],
    )
    stable_release = is_stable_release(configuration)

    os = parsed_args["os"]
    psrcloud = parsed_args["psrcloud"]

    exit_code = start_ecs_task_and_watch(;
        configuration = configuration,
        os = os,
        memory_in_gb = 8,
        overwrite = parsed_args["overwrite"],
    )

    if exit_code != 0
        return exit_code
    end

    return 0
end

exit(main(ARGS))
