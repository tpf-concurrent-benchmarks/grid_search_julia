module Works

using ..Intervals
using ..Aggregators

export Work, wsize, evaluate_for

macro INTERVALS()
    return :(3)
end

struct Work
    intervals::NTuple{@INTERVALS, Interval}
    aggregator::UInt8
    size::Int64
    function Work(intervals::NTuple{(@INTERVALS), Interval}, aggregator::UInt8 = Aggregators.Min)
        size = wsize(intervals)
        new(intervals, aggregator, size)
    end
end

function wsize(intervals::NTuple{(@INTERVALS), Interval})
    prod(isize.(intervals))
end

function calc_amount_of_missing_partitions(min_batches::Integer, curr_partitions_per_interval::Vector{Int})
    ceil(Int, min_batches / prod(curr_partitions_per_interval))
end


function calc_partitions_per_interval(self::Work, min_batches::Integer)
    curr_partitions_per_interval = fill(1, @INTERVALS)

    for interval_pos in 1:@INTERVALS
        missing_partitions = calc_amount_of_missing_partitions(min_batches, curr_partitions_per_interval)
        elements = isize(self.intervals[interval_pos])
        if elements > missing_partitions
            curr_partitions_per_interval[interval_pos] = missing_partitions
            break
        else
            curr_partitions_per_interval[interval_pos] = elements
        end
    end
    curr_partitions_per_interval
end

function unfold!(self::Work, values::Array{Float64, 2})
    for i in 1:@INTERVALS
        values[1, i] = self.intervals[i].istart
    end
    
    for pos in 2:self.size
        for i in 1:@INTERVALS
            values[pos, i] = values[pos - 1, i]
        end
        for (i, curr_val) in enumerate(@view values[pos - 1, :])
            start = Intervals.round_number(self.intervals[i].istart)
            _end = Intervals.round_number(self.intervals[i].iend)
            step = Intervals.round_number(self.intervals[i].istep)
            if curr_val + step < _end
                values[pos, i] = Intervals.round_number(curr_val + step)
                break
            else
                values[pos, i] = Intervals.round_number(start)
            end
        end
    end
    values
end

function split(self::Work, max_chunk_size::Integer)
    min_batches = ceil(Int, self.size / max_chunk_size)
    partitions_per_interval = calc_partitions_per_interval(self, min_batches)
    println("Partitions per interval: $partitions_per_interval")

    iterators = Vector{Vector{Interval}}(undef, length(self.intervals))

    for (interval_pos, interval) in enumerate(self.intervals)
        iterators[interval_pos] = Intervals.split_eager(interval, partitions_per_interval[interval_pos])
    end
    make_iterator(WorkPlan(iterators, self.aggregator))
end

function __griewanc_func(params::Params)
    a = params[1]
    b = params[2]
    c = params[3]
    1/4000 * (a^2 + b^2 + c^2) - cos(a) * cos(b / sqrt(2)) * cos(c / sqrt(3)) + 1
end

function evaluate_for(self::Work)
    results = Vector{Tuple{Params, Float64}}(undef, self.size)
    evaluate_for!(__griewanc_func, self, results)
end

function evaluate_for!(self::Work, values::Array{Float64, 2}, results::Vector{Tuple{Params, Float64}})
    evaluate_for!(__griewanc_func, self, values, results)
end

function evaluate_for!(f::Function, self::Work, values::Array{Float64, 2}, results::Vector)
    for (i, params) in enumerate(eachrow(unfold!(self, values)))
        params_converted = ntuple(j -> params[j], @INTERVALS)
        results[i] = (params_converted, f(params_converted))
    end
    aggregate(self.aggregator, results, self.size)
end




struct WorkPlan
    ints::Vector{Vector{Interval}}
    aggregator::UInt8
end

function make_iterator(self::WorkPlan)
    positions = fill(1, length(self.ints))
    size = prod(length.(self.ints))
    current_values = map(i -> self.ints[i][1], 1:length(self.ints))

    started = false
    get_next = function()
        if !started
            started = true
            return Work((current_values..., ), self.aggregator)
        end
        for i in 1:length(self.ints)
            positions[i]  = positions[i] % length(self.ints[i]) + 1
            current_values[i] = self.ints[i][positions[i]]
            if positions[i] != 1
                return Work((current_values..., ), self.aggregator)
            end
        end
        error("Unreachable")
    end
    (get_next() for _ in 1:size)

end

end