module Works

using ..Intervals
using ..Aggregators
# using ..CircularIterators

export Work, wsize, evaluate_for

struct Work
    intervals::Array{Interval}
    aggregator::Aggregator
    Work(intervals::Array{Interval}, aggregator::Aggregator = Aggregators.Mean) = new(intervals, aggregator)
end

function wsize(self::Work, precision::Integer = -1)
    prod(BigInt.(isize.(self.intervals, precision)))
end

function calc_amount_of_missing_partitions(min_batches::Integer, curr_partitions_per_interval::Vector{Int})
    ceil(Int, min_batches / prod(curr_partitions_per_interval))
end


function calc_partitions_per_interval(self::Work, min_batches::Integer)
    curr_partitions_per_interval = fill(1, length(self.intervals))

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

function unfold(self::Work, precision::Integer = -1)
    current = map(i -> i.istart, self.intervals)
    size = wsize(self, precision)
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
    (get_next() for _ in 1:size)
end

function split(self::Work, max_chunk_size::Integer, precision::Integer = -1)
    min_batches = ceil(Int, wsize(self) / max_chunk_size)
    partitions_per_interval = calc_partitions_per_interval(self, min_batches)

    iterators = Vector{Vector{Interval}}(undef, length(self.intervals))

    for (interval_pos, interval) in enumerate(self.intervals)
        iterators[interval_pos] = @time Intervals.split_eager(interval, partitions_per_interval[interval_pos], precision)
    end
    make_iterator(WorkPlan(iterators, self.aggregator))
end

function evaluate_for(self::Work, f::Function)
    results = Vector{Tuple{Params, Float64}}(undef, wsize(self))
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
            return Work(copy(current_values), self.aggregator)
        end
        for i in 1:length(self.ints)
            positions[i]  = positions[i] % length(self.ints[i]) + 1
            current_values[i] = self.ints[i][positions[i]]
            if positions[i] != 1
                return Work(copy(current_values), self.aggregator)
            end
        end
        error("Unreachable")
    end
    (get_next() for _ in 1:size)

end

end