include("initialize.jl")

using Distributed
@everywhere begin
	using Pkg
	Pkg.add("ProgressMeter")
	Pkg.instantiate()
	using ProgressMeter
end

@everywhere macro INTERVALS() return :(3) end

@everywhere include("Intervals.jl")
@everywhere include("Aggregators.jl")
@everywhere include("Works.jl")

@everywhere using .Intervals
@everywhere using .Aggregators
@everywhere using .Works

@everywhere const MAX_CHUNK_SIZE::Integer = 10000000
@everywhere RESULTS = Vector{Tuple{Aggregators.Params, Float64}}(undef, Int(2 * MAX_CHUNK_SIZE))

function aggregate_results(results::Vector{Aggregators.Result}, ::Val{Aggregators.Mean})
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

function aggregate_results(results::Vector{Aggregators.Result}, ::Val{Aggregators.Min})
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
	work = Work([Interval(-600, 600, 5, 3),
				 Interval(-600, 600, 5, 3),
				 Interval(-600, 600, 5, 3)], Aggregators.Min)
	sub_works = @time Works.split(work, 108000, 3)
	println("Got sub_works")
	pool = WorkerPool(workers())

	partial_results = @time distribute_work(sub_works_parts, pool)
end

GC.enable_logging(true)

main()