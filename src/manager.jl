# include("initialize.jl")
# using Distributed

using Pkg
Pkg.add("ProgressMeter")
Pkg.instantiate()
using ProgressMeter

include("Intervals.jl")
include("Aggregators.jl")
include("Works.jl")

using .Intervals
using .Aggregators
using .Works


function aggregate_results(results:: Vector{Aggregators.Result}, ::Val{Aggregators.Mean})
	mean = 0.0
	count = 0
	for (_, value, params_amount) in results
		new_count = count + params_amount
		a = mean * (count / new_count)
		b = value * (params_amount / new_count)
		mean = a + b
		count = new_count
	end
	return (mean, count)
end

function aggregate_results(results:: Vector{Aggregators.Result}, ::Val{Aggregators.Max})
	max_val = -Inf
	max_params = Params((0.0, 0.0, 0.0))
	for (params, value, _) in results
		if value > max_val
			max_val = value
			max_params = params
		end
	end
	return (max_val, max_params)
end

function aggregate_results(results:: Vector{Aggregators.Result}, ::Val{Aggregators.Min})
	min_val = Inf
	min_params = Params((0.0, 0.0, 0.0))
	for (params, value, _) in results
		if value < min_val
			min_val = value
			min_params = params
		end
	end
	return (min_val, min_params)
end

function aggregate_results(results:: Vector{Aggregators.Result}, aggregator::Aggregator)
	aggregate_results(results, Val(aggregator))
end

function griewank_func(params::Aggregators.Params)
	a = params[1]
	b = params[2]
	c = params[3]
	a + b + c
end

function evaluate_for_partition(sub_work_partition)
	map(Works.evaluate_for, sub_work_partition)
end

function distribute_work(sub_works_parts)
	@showprogress map(sub_works_parts) do sub_works_part
		evaluate_for_partition(sub_works_part)
	end
end

function main()
	precompile(Works.evaluate_for, (Works.Work{3},))

	work = Work((Interval(-600, 600, 1, 3),
				 Interval(-600, 600, 1, 3),
				 Interval(-600, 600, 1, 3)), Aggregators.Min)
	sub_works = @time collect(Works.split(work, 200000, 3))
	sub_works_parts = Iterators.partition(sub_works, 10)

	println("Got sub_works")
	# w = workers()
	# pool = WorkerPool(w)

	results = @time distribute_work(sub_works_parts)
	# println("Amount of results: $(length(results))")
end

# main()