module Aggregators

export Params, aggregate, Mean, Max, Min, Result

const Mean = 0x00
const Max = 0x01
const Min = 0x02

Params = NTuple{3, Float64}

struct Result
    params::Params
    value::Float64
    count::Int
    Result(params::Params, value::Float64) = new(params, value, 1)
    Result(value::Float64, count::Int) = new((0.0, 0.0, 0.0), value, count)
end

function aggregate(aggregator::UInt8, values::Vector{Tuple{Params, Float64}}, size::Integer)
    if aggregator == Mean
        return aggregate_mean(values, size)
    elseif aggregator == Max
        return aggregate_max(values, size)
    elseif aggregator == Min
        return aggregate_min(values, size)
    else
        error("Unknown aggregator")
    end
end

function aggregate_mean(values::Vector{Tuple{Params, Float64}}, size::Integer)
    mean = 0.0
    count = 0
    for (_, value) in @view values[1:size]
        mean = mean + (value - mean) / (count + 1)
        count = count + 1
    end
    return Result(mean, count)
end

function aggregate_max(values::Vector{Tuple{Params, Float64}}, size::Integer)
    max_val = -Inf
    max_params = Params((0.0, 0.0, 0.0))
    for (params, value) in @view values[1:size]
        if value > max_val
            max_val = value
            max_params = params
        end
    end
    return Result(max_params, max_val)
end

function aggregate_min(values::Vector{Tuple{Params, Float64}}, size::Integer)
    min_val = Inf
    min_params_pos = 0
    for (i, (_, value)) in enumerate(@view values[1:size])
        if value < min_val
            min_val = value
            min_params_pos = i
        end
    end
    return Result(values[min_params_pos][1], min_val)
end

end