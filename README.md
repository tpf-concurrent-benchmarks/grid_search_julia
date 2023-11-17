1. `make init`
2. `make build`
3. `make deploy`
4. `make manager_bash`

```
From worker 2:     Unfolding work - intervals: Interval[Interval(528.0, 536.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)]
Progress:  82%|██████████████████████████████████████████████████████████████████               |  ETA: 0:01:12ERROR: LoadError: UndefRefError: access to undefined reference
Stacktrace:
  [1] getindex
    @ ./essentials.jl:13 [inlined]
  [2] (::Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}})()
    @ Main.Works /opt/app/Works.jl:101
  [3] #11
    @ ./generator.jl:0 [inlined]
  [4] iterate
    @ ./generator.jl:47 [inlined]
  [5] iterate
    @ ./generator.jl:44 [inlined]
  [6] collect_to!
    @ ./array.jl:840 [inlined]
  [7] collect_to_with_first!
    @ ./array.jl:818 [inlined]
  [8] collect(itr::Base.Generator{Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}}, Base.var"#986#988"{Channel{Any}, Vector{Any}, Distributed.var"#224#227"{WorkerPool}, Base.var"#979#984"{Distributed.var"#208#210"{Distributed.var"#208#209#211"{WorkerPool, ProgressMeter.var"#45#48"{RemoteChannel{Channel{Bool}}, var"#5#6"}}}}, Base.var"#985#987"{Channel{Any}}}})
    @ Base ./array.jl:792
  [9] map(f::Function, A::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}})
    @ Base ./abstractarray.jl:3291
 [10] maptwice(wrapped_f::Function, chnl::Channel{Any}, worker_tasks::Vector{Any}, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}})
    @ Base ./asyncmap.jl:161
 [11] wrap_n_exec_twice
    @ ./asyncmap.jl:153 [inlined]
 [12] #async_usemap#974
    @ ./asyncmap.jl:103 [inlined]
 [13] async_usemap
    @ ./asyncmap.jl:84 [inlined]
 [14] #asyncmap#973
    @ ./asyncmap.jl:81 [inlined]
 [15] asyncmap
    @ ./asyncmap.jl:80 [inlined]
 [16] pmap(f::Function, p::WorkerPool, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}}; distributed::Bool, batch_size::Int64, on_error::Nothing, retry_delays::Vector{Any}, retry_check::Nothing)
    @ Distributed /usr/local/julia/share/julia/stdlib/v1.9/Distributed/src/pmap.jl:126
 [17] pmap(f::Function, p::WorkerPool, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}})
    @ Distributed /usr/local/julia/share/julia/stdlib/v1.9/Distributed/src/pmap.jl:99
 [18] macro expansion
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1035 [inlined]
 [19] macro expansion
    @ ./task.jl:476 [inlined]
 [20] macro expansion
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1034 [inlined]
 [21] macro expansion
    @ ./task.jl:476 [inlined]
 [22] progress_map(::Function, ::Vararg{Any}; mapfun::typeof(pmap), progress::Progress, channel_bufflen::Int64, kwargs::Base.Pairs{Symbol, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}      From worker 3:      Unfolding work - intervals: Interval[Interval(536.0, 540.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)])

    @ ProgressMeter ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1027
 [23] progress_map
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1018 [inlined]
 [24] macro expansion
    @ ./timing.jl:273 [inlined]
 [25] main()
    @ Main /opt/app/manager.jl:74
 [26] top-level scope
    @ /usr/local/julia/share/julia/stdlib/v1.9/Profile/src/Profile.jl:27
in expression starting at /opt/app/manager.jl:85
```

```
From worker 2:     Unfolding work - intervals: Interval[Interval(528.0, 536.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)]
Progress:  82%|██████████████████████████████████████████████████████████████████               |  ETA: 0:00:56ERROR: LoadError: UndefRefError: access to undefined reference
Stacktrace:
  [1] getindex
    @ ./essentials.jl:13 [inlined]
  [2] (::Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}})()
    @ Main.Works /opt/app/Works.jl:101
  [3] #11
    @ ./generator.jl:0 [inlined]
  [4] iterate
    @ ./generator.jl:47 [inlined]
  [5] iterate
    @ ./generator.jl:44 [inlined]
  [6] collect_to!
    @ ./array.jl:840 [inlined]
  [7] collect_to_with_first!
    @ ./array.jl:818 [inlined]
  [8] collect(itr::Base.Generator{Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}}, Base.var"#986#988"{Channel{Any}, Vector{Any}, Distributed.var"#224#227"{WorkerPool}, Base.var"#979#984"{Distributed.var"#208#210"{Distributed.var"#208#209#211"{WorkerPool, ProgressMeter.var"#45#48"{RemoteChannel{Channel{Bool}}, var"#5#6"}}}}, Base.var"#985#987"{Channel{Any}}}})
    @ Base ./array.jl:792
  [9] map(f::Function, A::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}})
    @ Base ./abstractarray.jl:3291
 [10] maptwice(wrapped_f::Function, chnl::Channel{Any}, worker_tasks::Vector{Any}, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}}      From worker 3:Unfolding work - intervals: Interval[Interval(536.0, 540.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)])

    @ Base ./asyncmap.jl:161
 [11] wrap_n_exec_twice
    @ ./asyncmap.jl:153 [inlined]
 [12] #async_usemap#974
    @ ./asyncmap.jl:103 [inlined]
 [13] async_usemap
    @ ./asyncmap.jl:84 [inlined]
 [14] #asyncmap#973
    @ ./asyncmap.jl:81 [inlined]
 [15] asyncmap
    @ ./asyncmap.jl:80 [inlined]
 [16] pmap(f::Function, p::WorkerPool, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}}; distributed::Bool, batch_size::Int64, on_error::Nothing, retry_delays::Vector{Any}, retry_check::Nothing)
    @ Distributed /usr/local/julia/share/julia/stdlib/v1.9/Distributed/src/pmap.jl:126
 [17] pmap(f::Function, p::WorkerPool, c::Base.Generator{UnitRange{Int64}, Main.Works.var"#11#14"{Main.Works.var"#10#13"{Main.Works.WorkPlan, Vector{Interval}, Vector{Int64}}}})
    @ Distributed /usr/local/julia/share/julia/stdlib/v1.9/Distributed/src/pmap.jl:99
 [18] macro expansion
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1035 [inlined]
 [19] macro expansion
    @ ./task.jl:476 [inlined]
 [20] macro expansion
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1034 [inlined]
 [21] macro expansion
    @ ./task.jl:476 [inlined]
 [22] progress_map(::Function, ::Vararg{Any}; mapfun::typeof(pmap), progress::Progress, channel_bufflen::Int64, kwargs::Base.Pairs{Symbol, Union{}, Tuple{}, NamedTuple{(), Tuple{}}})
    @ ProgressMeter ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1027
 [23] progress_map
    @ ~/.julia/packages/ProgressMeter/vnCY0/src/ProgressMeter.jl:1018 [inlined]
 [24] macro expansion
    @ ./timing.jl:273 [inlined]
 [25] main()
    @ Main /opt/app/manager.jl:74
 [26] top-level scope
    @ /usr/local/julia/share/julia/stdlib/v1.9/Profile/src/Profile.jl:27
in expression starting at /opt/app/manager.jl:85
```

```
From worker 2:     Unfolding work - intervals: Interval[Interval(528.0, 536.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)]

From worker 3:      Unfolding work - intervals: Interval[Interval(536.0, 540.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)])

From worker 2:     Unfolding work - intervals: Interval[Interval(528.0, 536.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)]

From worker 3:Unfolding work - intervals: Interval[Interval(536.0, 540.0, 2.0, 3), Interval(-600.0, 600.0, 2.0, 3), Interval(-600.0, 600.0, 1.0, 3)])
```
