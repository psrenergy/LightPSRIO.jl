function main(args::Vector{String})
    args = Args(args)

    L = LightPSRIO.initialize([args.case_path])
    LightPSRIO.run_file(L, args.script_path)
    finalize(L)

    return nothing
end

function julia_main()::Cint
    try
        main(ARGS)
    catch
        return 1
    end
    return 0
end
