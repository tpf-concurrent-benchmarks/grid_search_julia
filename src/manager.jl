# include("initialize.jl")
using Distributed

using Pkg
Pkg.add("ProgressMeter")
Pkg.instantiate()
using ProgressMeter

@everywhere include("Intervals.jl")
@everywhere include("Aggregators.jl")
@everywhere include("Works.jl")

using .Intervals
using .Aggregators
using .Works

@everywhere const MAX_CHUNK_SIZE::Integer = 1500000
@everywhere RESULTS = Vector{Tuple{Aggregators.Params, Float64}}(undef, MAX_CHUNK_SIZE)


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

@everywhere function evaluate_for_partition(sub_work_partition)
	map(sub_work_partition) do sub_work
		Works.evaluate_for!(sub_work, RESULTS)
	end
end

function distribute_work(sub_works_parts, pool)
	@showprogress pmap(pool, sub_works_parts) do sub_work_partition
		evaluate_for_partition(sub_work_partition)
	end
end

function main()
	precompile(Works.evaluate_for, (Works.Work{3},))
	work = Work((Interval(-600, 600, 0.2, 3),
				 Interval(-600, 600, 0.2, 3),
				 Interval(-600, 600, 0.2, 3)), Aggregators.Min)
	sub_works = @time Works.split(work, MAX_CHUNK_SIZE, 3)
	sub_works_parts = Iterators.partition(sub_works, 10)

	println("Got sub_works")
	pool = WorkerPool(workers())

	results = @time distribute_work(sub_works_parts, pool)
	# println("Amount of results: $(length(results))")
end

main()