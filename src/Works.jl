module Works

using ..Intervals
using ..Aggregators

export Work, wsize, evaluate_for

macro INTERVALS()
    return :(3)
end

struct Work
    intervals::NTuple{@INTERVALS, Interval}
    aggregator::Aggregator
    size::Int64
    function Work(intervals::NTuple{(@INTERVALS), Interval}, aggregator::Aggregator = Aggregators.Min, precision::Int = 3)
        size = wsize(intervals, precision)
        new(intervals, aggregator, size)
    end
end

function wsize(intervals::NTuple{(@INTERVALS), Interval}, precision::Int = -1)
    prod(isize.(intervals, precision))
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

function unfold(self::Work, precision::Integer = -1)
    values = Array{Float64, 2}(undef, self.size, @INTERVALS)

    values[1, :] = collect(map(interval -> interval.istart, self.intervals))

    for pos in 2:self.size
        values[pos, :] = values[pos - 1, :]
        for (i, curr_val) in enumerate(values[pos - 1])
            start = Intervals.round_number(self.intervals[i].istart, precision)
            _end = Intervals.round_number(self.intervals[i].iend, precision)
            step = Intervals.round_number(self.intervals[i].istep, precision)
            if curr_val + step < _end
                values[pos, i] = Intervals.round_number(curr_val + step, precision)
                break
            else
                values[pos, i] = Intervals.round_number(start, precision)
            end
        end
    end
    values
end

function split(self::Work, max_chunk_size::Integer, precision::Int = -1)
    min_batches = ceil(Int, self.size / max_chunk_size)
    partitions_per_interval = calc_partitions_per_interval(self, min_batches)
    println("Partitions per interval: $partitions_per_interval")

    iterators = Vector{Vector{Interval}}(undef, length(self.intervals))

    for (interval_pos, interval) in enumerate(self.intervals)
        iterators[interval_pos] = @time Intervals.split_eager(interval, partitions_per_interval[interval_pos], precision)
    end
    make_iterator(WorkPlan(iterators, self.aggregator))
end

function __griewanc_func(params::Params)
    a = params[1]
    b = params[2]
    c = params[3]
    1/4000 * (a^2 + b^2 + c^2) - cos(a) * cos(b / sqrt(2)) * cos(c / sqrt(3)) + 1
end

function evaluate_for!(self::Work, results::Vector{Tuple{Params, Float64}})
    evaluate_for!(__griewanc_func, self, results)
end

function evaluate_for!(f::Function, self::Work, results::Vector)
    for (i, params) in enumerate(eachrow(unfold(self)))
        params_converted = ntuple(j -> params[j], @INTERVALS)
        results[i] = (params_converted, f(params_converted))
    end
    aggregate(self.aggregator, results, self.size)
end




struct WorkPlan
    ints::Vector{Vector{Interval}}
    aggregator::Aggregator
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