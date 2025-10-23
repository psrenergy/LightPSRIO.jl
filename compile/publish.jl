import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using ArgParse
using PSRContinuousDeployment

const SLACK_CHANNEL = "C09NA4F20MQ"

const PERSONAL_ACCESS_TOKEN = ENV["PERSONAL_ACCESS_TOKEN"]
const SLACK_TOKEN = ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"]

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

    if !is_release_tag_available(configuration, PERSONAL_ACCESS_TOKEN)
        error("Version $(configuration.version) already exists")
        exit(1)
    end

    binary_path = if Sys.iswindows()
        create_setup(
            configuration;
            sign = stable_release,
        )
    else
        create_zip(;
            configuration = configuration,
        )
    end

    url = deploy_to_psrmodels(;
        configuration = configuration,
        path = binary_path,
        overwrite = parsed_args["overwrite"],
    )

    notify_slack_channel(;
        configuration = configuration,
        slack_token = SLACK_TOKEN,
        channel = SLACK_CHANNEL,
        url = url,
    )

    return 0
end

main(ARGS)
