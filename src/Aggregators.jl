module Aggregators

export Aggregator, Params, aggregate

@enum Aggregator Mean Max Min

Params = Vector{Float64}

function aggregate(aggregator::Aggregator, values::Vector{Tuple{Params, Float64}})
    aggregate(Val(aggregator), values)
end

function aggregate(::Val{Mean}, values::Vector{Tuple{Params, Float64}})
    mean = 0.0
    count = 0
    for (_, value) in values
        mean = mean + (value - mean) / (count + 1)
        count = count + 1
    end
    return (mean, count)
end

function aggregate(::Val{Max}, values::Vector{Tuple{Params, Float64}})
    max_val = -Inf
    max_params = Params([])
    for (params, value) in values
        if value > max_val
            max_val = value
            max_params = params
        end
    end
    return (max_val, max_params)
end

function aggregate(::Val{Min}, values::Vector{Tuple{Params, Float64}})
    min_val = Inf
    min_params = Params([])
    for (params, value) in values
        if value < min_val
            min_val = value
            min_params = params
        end
    end
    return (min_val, min_params)
end

end