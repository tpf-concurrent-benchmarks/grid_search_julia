@everywhere module Works

using ..Intervals
using ..Aggregators
using ..CircularIterators

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
    
    get_next = function()
        curr_copy = copy(current)
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
        curr_copy
    end
    (get_next() for _ in 1:size)
end

function split(self::Work, max_chunk_size::Integer, precision::Integer = -1)
    min_batches = ceil(Int, wsize(self) / max_chunk_size)
    partitions_per_interval = calc_partitions_per_interval(self, min_batches)

    iterators = Array{CircularIterator{Interval}}(undef, length(self.intervals))
    for (interval_pos, interval) in enumerate(self.intervals)
        collected = Intervals.split_eager(interval, partitions_per_interval[interval_pos], precision)
        iterators[interval_pos] = CircularIterator(collected, partitions_per_interval[interval_pos], precision)
    end
    make_iterator(WorkPlan(iterators, self.aggregator))
end

function evaluate_for(self::Work, f::Function)
    results = map(i -> (i, f(i)), unfold(self))
    aggregate(self.aggregator, results)
end



struct WorkPlan
    ints::Vector{CircularIterator{Interval}}
    aggregator::Aggregator
end

function make_iterator(self::WorkPlan)
    positions = fill(1, length(self.ints))
    size = prod(BigInt.(map(c -> c.len, self.ints)))
    res = map(c -> Base.iterate(c), self.ints)
    current_values = map(c -> c[1], res)
    iterators_states = map(c -> c[2], res)

    started = false
    get_next = function()
        if !started
            started = true
            return Work(copy(current_values), self.aggregator)
        end
        for i in 1:length(self.ints)
            positions[i] += 1
            new_value, new_state = Base.iterate(self.ints[i], iterators_states[i])
            current_values[i] = new_value
            iterators_states[i] = new_state
            if positions[i] < self.ints[i].len + 1
                break
            end
            positions[i] = 1
        end
        Work(copy(current_values), self.aggregator)
    end
    (get_next() for _ in 1:size)

end

end