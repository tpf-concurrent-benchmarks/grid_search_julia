module Intervals

export Interval, interval_size, unfold, split, isize

struct Interval
    istart::Float64
    iend::Float64
    istep::Float64
    iprec::Integer
    Interval(istart::Float64, iend::Float64, istep::Float64, iprec::Integer = -1) = new(istart, iend, istep, iprec)
    Interval(istart::Number, iend::Number, istep::Number, iprec::Integer = -1) = new(Float64(istart), Float64(iend), Float64(istep), iprec)
end

function round_number(n::Float64, precision::Integer)::Float64
    if precision == -1
        return n
    end
    """
    scale = 10 ^ precision
    round(n * scale) / scale
    """
    round(n, digits = precision)
end

function isize(self::Interval, precision::Integer = -1)
    ceil(Int, round_number((self.iend - self.istart) / self.istep, precision))
end

function unfold(self::Interval)
    curr = self.istart
    get_next = function()
        old_curr = curr
        curr = round_number(curr + self.istep, self.iprec)
        old_curr
    end
    (get_next() for _ in 0:isize(self, self.iprec) - 1)
end

function split_evenly(self::Interval, amount_of_sub_intervals::Integer, precision::Integer = -1)
    make_sub_interval = function(pos)
        size = isize(self, precision)
        sub_start = round_number(self.istart + pos * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_end = round_number(self.istart + (pos + 1) * floor(size / amount_of_sub_intervals) * self.istep, precision)
        Interval(sub_start, sub_end, self.istep, precision)
    end
    (make_sub_interval(pos) for pos in 0:amount_of_sub_intervals - 1)
end

function split(self::Interval, amount_of_sub_intervals::Integer, precision::Integer = -1)
    if (isize(self, precision) % amount_of_sub_intervals == 0)
        return split_evenly(self, amount_of_sub_intervals, precision)
    end
    size = isize(self, precision)
    max_elems_per_interval = ceil(size / amount_of_sub_intervals)
    amount_of_sub_intervals_of_full_size = floor(Int, (size - amount_of_sub_intervals) / (max_elems_per_interval - 1))
    sub_end = 0.0
    make_sub_intervals_of_full_size = function(pos)
        sub_start = round_number(self.istart + pos * max_elems_per_interval * self.istep, precision)
        sub_end = round_number(min(self.iend, sub_start + max_elems_per_interval * self.istep), precision)
        Interval(sub_start, sub_end, self.istep, precision)
    end
    last_sub_end = round_number(self.istart + amount_of_sub_intervals_of_full_size * max_elems_per_interval * self.istep, precision)

    remaining_interval = Interval(last_sub_end, self.iend, self.istep, precision)
    remaining_amount_of_sub_intervals = amount_of_sub_intervals - amount_of_sub_intervals_of_full_size

    intervals_of_full_size = (make_sub_intervals_of_full_size(pos) for pos in 0:amount_of_sub_intervals_of_full_size - 1)
    remaining_intervals = split(remaining_interval, remaining_amount_of_sub_intervals, precision)

    Iterators.flatten([intervals_of_full_size, remaining_intervals])
end

function split_evenly_eager!(self::Interval,
                             amount_of_sub_intervals::Integer,
                             precision::Integer,
                             sub_intervals::Vector{Interval},
                             start_pos::Integer)

    for pos in 0:amount_of_sub_intervals - 1
        size = isize(self, precision)
        sub_start = round_number(self.istart + pos * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_end = round_number(self.istart + (pos + 1) * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_intervals[pos + start_pos] = Interval(sub_start, sub_end, self.istep, precision)
    end
    sub_intervals
end


function split_eager_rec!(self::Interval,
                          amount_of_sub_intervals::Integer,
                          precision::Integer,
                          sub_intervals::Vector{Interval},
                          start_pos::Integer)
    
    if (isize(self, precision) % amount_of_sub_intervals == 0)
        return split_evenly_eager!(self, amount_of_sub_intervals, precision, sub_intervals, start_pos)
    end
    size = isize(self, precision)
    max_elems_per_interval = ceil(size / amount_of_sub_intervals)
    amount_of_sub_intervals_of_full_size = floor(Int, (size - amount_of_sub_intervals) / (max_elems_per_interval - 1))
    sub_end = 0.0
    
    for pos in 0:amount_of_sub_intervals_of_full_size - 1
        sub_start = round_number(self.istart + pos * max_elems_per_interval * self.istep, precision)
        sub_end = round_number(min(self.iend, sub_start + max_elems_per_interval * self.istep), precision)
        new_interval = Interval(sub_start, sub_end, self.istep, precision)
        sub_intervals[start_pos + pos] = new_interval
    end
    remaining_interval = Interval(sub_end, self.iend, self.istep, precision)

    remaining_amount_of_sub_intervals = amount_of_sub_intervals - amount_of_sub_intervals_of_full_size

    split_eager_rec!(remaining_interval,
                    remaining_amount_of_sub_intervals,
                    precision,
                    sub_intervals,
                    amount_of_sub_intervals_of_full_size + 1)
    
    sub_intervals
end

function split_eager(self::Interval, amount_of_sub_intervals::Integer, precision::Integer = -1)
    sub_intervals = Vector{Interval}(undef, amount_of_sub_intervals)
    split_eager_rec!(self, amount_of_sub_intervals, precision, sub_intervals, 1)
end

end