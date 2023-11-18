using Distributed

include("Intervals.jl")
include("Aggregators.jl")
include("Works.jl")

using ..Works
using ..Intervals
using ..Aggregators


function assert_work_is_split_correctly(work::Work{N}, max_chunk_size::Integer) where {N}
    unfolded_work = collect(Works.unfold(work, 5))
    split_work = @time Works.split(work, max_chunk_size, 5)

    unfolded_split_work = []
    for w in split_work
        unfolded_split_work = append!(unfolded_split_work, collect(Works.unfold(w, 5)))
    end

    for w in unfolded_split_work
        if !(w in unfolded_work)
            error("$w is not in unfolded_work - $unfolded_work")
        else
            deleteat!(unfolded_work, findfirst(x -> x == w, unfolded_work))
        end
    end
    if length(unfolded_work) > 0
        error("unfolded_work is not empty: $unfolded_work")
    end
end

function assert_interval_is_split_correctly(interval::Interval, partitions::Integer)
  unfolded_interval = collect(Intervals.unfold(interval))
  split_interval = @time Intervals.split_eager(work, partitions, 5)

  unfolded_split_intervals = []
  for i in split_interval
      unfolded_split_intervals = append!(unfolded_split_intervals, collect(Intervals.unfold(i)))
  end

  for i in unfolded_split_intervals
      if !(i in unfolded_interval)
          error("$i is not in unfolded_interval - $unfolded_interval")
      else
          deleteat!(unfolded_interval, findfirst(x -> x == w, unfolded_interval))
      end
  end
  if length(unfolded_interval) > 0
      error("unfolded_interval is not empty: $unfolded_interval")
  end
end


function run_tests()
    assert_work_is_split_correctly(Work((Interval(0, 1, 1), )), 1)
    assert_work_is_split_correctly(Work((Interval(-1, 0, 1), )), 1)
    assert_work_is_split_correctly(Work((Interval(0, 2, 1), )), 1)
    assert_work_is_split_correctly(Work((Interval(0, 2, 1), )), 2)
    assert_work_is_split_correctly(Work((Interval(0, 10, 3), )), 1)
    assert_work_is_split_correctly(Work((Interval(0, 10, 3), )), 2)
    assert_work_is_split_correctly(Work((Interval(-10, 0, 3), )), 1)
    assert_work_is_split_correctly(Work((Interval(-10, 0, 3), )), 2)
    assert_work_is_split_correctly(Work((Interval(0, 10, 4.3), )), 3)

    
    assert_work_is_split_correctly(Work((Interval(544, 600, 2.0, 3), )), 4)
    
    assert_work_is_split_correctly(Work((Interval(-10, 0, 4.3), )), 3)
    assert_work_is_split_correctly(Work((Interval(0, 4, 1),
                                         Interval(0, 2, 1))), 7)

    assert_work_is_split_correctly(Work((Interval(0, 3, 1),
                                         Interval(0, 3, 1))), 2)
    assert_work_is_split_correctly(Work((Interval(0, 10, 1),
                                         Interval(0, 10, 1),
                                         Interval(0, 10, 1))), 13)

    assert_work_is_split_correctly(
        Work((Interval(0.0, 12.3, 8.4, 5),
              Interval(5.3, 8.99, 1.2, 5),
              Interval(3.0, 3.3, 0.1, 5))), 5)


    assert_work_is_split_correctly(
        Work((Interval(0, 12.3, 8.4),
              Interval(5.3, 8.99, 1.2),
              Interval(3, 3.3, 0.1),
              Interval(0, 12.3, 8.4))), 5)

              assert_work_is_split_correctly(
                Work((Interval(-6.5, -5, 0.01))), 5)
                
                assert_work_is_split_correctly(
        Work((Interval(0, 12, 3),
              Interval(-8, 4, 2),
              Interval(3, 12, 3))), 5)
    
    assert_interval_is_split_correctly(Interval(0, 10, 4.3), 9)
    
    println("All tests passed!")
end

run_tests()