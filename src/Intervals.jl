module Intervals

export Interval, interval_size, unfold, split, isize

struct Interval
    istart::Float64
    iend::Float64
    istep::Float64
    iprec::Int
    Interval(istart::Float64, iend::Float64, istep::Float64, iprec::Int = -1) = new(istart, iend, istep, iprec)
    Interval(istart::Number, iend::Number, istep::Number, iprec::Int = -1) = new(Float64(istart), Float64(iend), Float64(istep), iprec)
end

function round_number(n::Float64, precision::Int)::Float64
    if precision == -1
        return n
    end
    round(n, digits = precision)
end

function isize(self::Interval, precision::Int = -1)
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

function split_evenly(self::Interval, amount_of_sub_intervals::Int, precision::Int = -1)
    make_sub_interval = function(pos)
        size = isize(self, precision)
        sub_start = round_number(self.istart + pos * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_end = round_number(self.istart + (pos + 1) * floor(size / amount_of_sub_intervals) * self.istep, precision)
        Interval(sub_start, sub_end, self.istep, precision)
    end
    (make_sub_interval(pos) for pos in 0:amount_of_sub_intervals - 1)
end

function split(self::Interval, amount_of_sub_intervals::Int, precision::Int = -1)
  split_eager(self, amount_of_sub_intervals, precision)
end

function split_evenly_eager!(self::Interval,
                             amount_of_sub_intervals::Int,
                             precision::Int,
                             sub_intervals::Vector{Interval},
                             start_pos::Int)

    for pos in 0:amount_of_sub_intervals - 1
        size = isize(self, precision)
        sub_start = round_number(self.istart + pos * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_end = round_number(self.istart + (pos + 1) * floor(size / amount_of_sub_intervals) * self.istep, precision)
        sub_intervals[pos + start_pos] = Interval(sub_start, sub_end, self.istep, precision)
    end
    sub_intervals
end


function split_eager_rec!(self::Interval,
                          amount_of_sub_intervals::Int,
                          precision::Int,
                          sub_intervals::Vector{Interval},
                          start_pos::Int)
    
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
                    amount_of_sub_intervals_of_full_size + start_pos)
    
    sub_intervals
end

function split_eager(self::Interval, amount_of_sub_intervals::Int, precision::Int = -1)
    sub_intervals = Vector{Interval}(undef, amount_of_sub_intervals)
    split_eager_rec!(self, amount_of_sub_intervals, precision, sub_intervals, 1)
end

end