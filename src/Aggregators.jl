module Aggregators

export Aggregator, Params, aggregate

@enum Aggregator Mean Max Min

Params = NTuple{3, Float64}

struct Result
    params::Params
    value::Float64
    count::Int
    Result(params::Params, value::Float64) = new(params, value, 1)
    Result(value::Float64, count::Int) = new((0.0, 0.0, 0.0), value, count)
end

function aggregate(aggregator::Aggregator, values::Vector{Tuple{Params, Float64}})
    ret = aggregate(Val(aggregator), values)
    # free values from memory
    
end

function aggregate(::Val{Mean}, values::Vector{Tuple{Params, Float64}})
    mean = 0.0
    count = 0
    for (_, value) in values
        mean = mean + (value - mean) / (count + 1)
        count = count + 1
    end
    return Result(mean, count)
end

function aggregate(::Val{Max}, values::Vector{Tuple{Params, Float64}})
    max_val = -Inf
    max_params = Params((0.0, 0.0, 0.0))
    for (params, value) in values
        if value > max_val
            max_val = value
            max_params = params
        end
    end
    return Result(max_params, max_val)
end

function aggregate(::Val{Min}, values::Vector{Tuple{Params, Float64}})
    min_val = Inf
    min_params = Params((0.0, 0.0, 0.0))
    for (params, value) in values
        if value < min_val
            min_val = value
            min_params = params
        end
    end
    return Result(min_params, min_val)
end

end