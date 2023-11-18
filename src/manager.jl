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

using .Intervals
using .Aggregators
using .Works

@everywhere const MAX_CHUNK_SIZE::Integer = 10000000
@everywhere RESULTS = Vector{Tuple{Aggregators.Params, Float64}}(undef, Int(2 * MAX_CHUNK_SIZE))

function aggregate_results(results::Vector{Aggregators.Result}, ::Val{Aggregators.Mean})
	mean = 0.0
	count = 0
	for result in results
		new_count = count + result.params_amount
		a = mean * (count / new_count)
		b = result.value * (result.params_amount / new_count)
		mean = a + b
		count = new_count
	end
	return (mean, count)
end

function aggregate_results(results:: Vector{Aggregators.Result}, ::Val{Aggregators.Max})
	max_val = -Inf
	max_params = Params((0.0, 0.0, 0.0))
	for result in results
		if result.value > max_val
			max_val = result.value
			max_params = result.params
		end
	end
	return (max_val, max_params)
end

function aggregate_results(results::Vector{Aggregators.Result}, ::Val{Aggregators.Min})
	min_val = Inf
	min_params = Params((0.0, 0.0, 0.0))
	for result in results
		if result.value < min_val
			min_val = result.value
			min_params = result.params
		end
	end
	return (min_val, min_params)
end

function aggregate_results(results::Vector{Aggregators.Result}, aggregator::Aggregator)
	aggregate_results(results, Val(aggregator))
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
	precompile(Works.unfold, (Works.Work, Int))

	work = Work((Interval(-600, 600, 0.2, 3),
				 Interval(-600, 600, 0.2, 3),
				 Interval(-600, 600, 0.2, 3)), Aggregators.Min)
	sub_works = @time Works.split(work, MAX_CHUNK_SIZE, 3)
	sub_works_parts = Iterators.partition(sub_works, 10)

	println("Got sub_works")
	pool = WorkerPool(workers())

	partial_results = @time distribute_work(sub_works_parts, pool)
  flat_results = reduce(vcat, partial_results)

  agg = aggregate_results(flat_results, work.aggregator)
  println("Result: $agg")
end

main()