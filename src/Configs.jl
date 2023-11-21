module Configs

using Distributed

export Config

struct Config
    work_path::String
    logger_ip::String
    logger_port::Int
    logger_prefix::String
    function Config( config_path::String )
        # receives a .env file path and loads the config from it aswell as the environment variables

        # load the config file
        config_file = open(config_path)
        config = Dict{String, String}()
        for line in eachline(config_file)
            if line[1] == '#'
                continue
            end
            key, value = split(line, '=')
            config[key] = value
        end
        close(config_file)

        if haskey(ENV, "NODE_ID")
            config["LOGGER_PREFIX"] = ENV["NODE_ID"]
        else
            config["LOGGER_PREFIX"] = "worker_" * string(myid())
        end

        # create the config struct
        new(config["WORK_PATH"], config["LOGGER_IP"], parse(Int, config["LOGGER_PORT"]), config["LOGGER_PREFIX"])

    end

end

end