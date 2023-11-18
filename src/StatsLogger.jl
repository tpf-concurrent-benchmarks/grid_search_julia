Pkg.add("StatsdClient")
Pkg.instantiate()

using StatsdClient

const STATSD_HOST = "localhost"
const STATSD_PORT = 8125
const STATSD_PREFIX = "julia"

const statsd_client = StatsdClient.Statsd(STATSD_HOST, STATSD_PORT)

function increment( metric::String, value::Int64 = 1 )
  _metric = "$STATSD_PREFIX.$metric"
  StatsdClient.increment( statsd_client,_metric , value )
end
  
function decrement( metric::String, value::Int64 = 1 )
  _metric = "$STATSD_PREFIX.$metric"
  StatsdClient.decrement( statsd_client, _metric, value )
end

function gauge( metric::String, value::Int64 )
  _metric = "$STATSD_PREFIX.$metric"
  StatsdClient.gauge( statsd_client, _metric, value )
end

function runAndMeasure( metric::String, f::Function )
  start = time()
  f()
  elapsed = time() - start
  _metric = "$STATSD_PREFIX.$metric"
  gauge( _metric, elapsed )
end