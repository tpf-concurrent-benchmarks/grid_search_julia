include("initialize.jl")
using Distributed
@everywhere using Pkg
@everywhere Pkg.add("ProgressMeter")
@everywhere Pkg.instantiate()
using ProgressMeter


include("Intervals.jl")
include("Aggregators.jl")
# include("CircularIterators.jl")
include("Works.jl")

using .Intervals
using .Aggregators
using .Works

function aggregate_results(results, ::Val{Aggregators.Mean})
	mean = 0.0
	count = 0
	for (value, params_amount) in results
		new_count = count + params_amount
		a = mean * (count / new_count)
		b = value * (params_amount / new_count)
		mean = a + b
		count = new_count
	end
	return (mean, count)
end

function aggregate_results(results, ::Val{Aggregators.Max})
	max_val = -Inf
	max_params = Params([])
	for (value, params) in results
		if value > max_val
			max_val = value
			max_params = params
		end
	end
	return (max_val, max_params)
end

function aggregate_results(results, ::Val{Aggregators.Min})
	min_val = Inf
	min_params = Params([])
	for (value, params) in results
		if value < min_val
			min_val = value
			min_params = params
		end
	end
	return (min_val, min_params)
end

function aggregate_results(results, aggregator::Aggregator)
	aggregate_results(results, Val(aggregator))
end

@everywhere function griewank_func(params::Vector{Float64})
	a = params[1]
	b = params[2]
	c = params[3]
	1/4000 * (a^2 + b^2 + c^2) - cos(a) * cos(b / sqrt(2)) * cos(c / sqrt(3)) + 1
end


function main()
	work = Work([Interval(-600, 600, 5, 3),
				 Interval(-600, 600, 5, 3),
				 Interval(-600, 600, 5, 3)], Aggregators.Min)
	sub_works = @time Works.split(work, 108000, 3)
	println("Got sub_works")
	w = workers()
	pool = WorkerPool(w)
	results = @time @showprogress pmap(pool, sub_works) do sub_work
		Works.evaluate_for(sub_work, griewank_func)
	end
	println("Amount of results: $(length(results))")
	result = aggregate_results(results, Aggregators.Min)
	println("Result: $result")
end

main()