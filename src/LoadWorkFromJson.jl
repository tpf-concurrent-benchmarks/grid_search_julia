module LoadWorkFromJson

import JSON

using ..Intervals
using ..Aggregators
using ..Works

export load_work

function load_work( data_path::String )
    file = open(data_path)
    data = JSON.parse(read(file, String))
    close(file)
    
    intervals = []
    for interval in data["data"]
        push!(intervals, Interval(interval[1], interval[2], interval[3]))
    end

    agg = data["agg"]
    if agg == "MIN" || agg == "min"
        agg = Aggregators.Min
    elseif agg == "MAX" || agg == "max"
        agg = Aggregators.Max
    elseif agg == "MEAN" || agg == "mean"
        agg = Aggregators.Mean
    else
        agg = Aggregators.Min
    end

    Work(tuple(intervals...), agg)
end

end