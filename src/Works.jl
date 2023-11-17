module Works

using ..Intervals
using ..Aggregators
# using ..CircularIterators

export Work, wsize, evaluate_for

struct Work{N}
    intervals::NTuple{N, Interval}
    aggregator::Aggregator
    size::UInt64
    function Work(intervals::NTuple{N, Interval}, aggregator::Aggregator, precision::Int = 3) where {N}
        size = wsize(intervals, precision)
        new{N}(intervals, aggregator, size)
    end
end

function wsize(intervals::NTuple{N, Interval}, precision::Int = -1) where {N}
    prod(isize.(intervals, precision))
end

function calc_amount_of_missing_partitions(min_batches::Integer, curr_partitions_per_interval::Vector{Int})
    ceil(Int, min_batches / prod(curr_partitions_per_interval))
end


function calc_partitions_per_interval(self::Work{N}, min_batches::Integer) where {N}
    curr_partitions_per_interval = fill(1, N)

    for interval_pos in 1:length(self.intervals)
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

function unfold(self::Work{N}, precision::Integer = -1) where {N}
    current = collect(map(i -> i.istart, self.intervals))
    started = false

    get_next = function()
        if !started
            started = true
            return current
        end
        for (i, curr_val) in enumerate(current)
            start = Intervals.round_number(self.intervals[i].istart, precision)
            _end = Intervals.round_number(self.intervals[i].iend, precision)
            step = Intervals.round_number(self.intervals[i].istep, precision)
            if curr_val + step < _end
                current[i] = Intervals.round_number(curr_val + step, precision)
                break
            else
                current[i] = start
            end
        end
        current
    end
    (get_next() for _ in 1:self.size)
end

function split(self::Work{N}, max_chunk_size::Integer, precision::Int = -1) where {N}
    println("Splitting with $N intervals")
    min_batches = ceil(Int, self.size / max_chunk_size)
    partitions_per_interval = calc_partitions_per_interval(self, min_batches)

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

function evaluate_for(self::Work{3})
    evaluate_for(__griewanc_func, self)
end

function evaluate_for(f::Function, self::Work{N}) where {N}
    results = Vector{Tuple{Params, Float64}}(undef, self.size)
    for (i, params) in enumerate(unfold(self))
        params_converted = (params...,)
        # print("params_converted: $params_converted\n")
        results[i] = (params_converted, f(params_converted))
    end
    aggregate(self.aggregator, results)
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