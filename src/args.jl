struct Args
    script_path::String
    case_path::String

    function Args(args::Vector{String})
        s = ArgParse.ArgParseSettings()

        #! format: off
        ArgParse.@add_arg_table! s begin
            "--script"
            dest_name = "script_path"
            help = "script path"
            arg_type = String
            "case_path"
            help = "case path"
            arg_type = String
            default = pwd()
        end
        #! format: on

        parsed_args = ArgParse.parse_args(args, s)
        return new(parsed_args["script_path"], parsed_args["case_path"])
    end
end
