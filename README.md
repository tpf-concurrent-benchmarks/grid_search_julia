# Grid Search - Julia

## Objective

This is a Julia implementation of a system for performing a grid search under [common specifications](https://github.com/tpf-concurrent-benchmarks/docs/tree/main/grid_search) defined for multiple languages.

The objective of this project is to benchmark the language on a real-world distributed system.

## Deployment

### Requirements

- [Docker >3](https://www.docker.com/) (needs docker swarm)
- [Julia](https://julialang.org/downloads/) (for local builds)

### Configuration

- **Number of replicas:** `N_WORKERS` constant is defined in the `Makefile` file.
- **Data config:** in `src/resources/data.json` you can define (this config is built into the container):
  - `data`: Intervals for each parameter, in format: [start, end, step, precision]
  - `agg`: Aggregation function to be used: MIN | MAX | AVG
  - `maxItemsPerBatch`: Maximum number of items per batch (batches are sub-intervals)
- **Manager config:** in `src/resources/config.env` you can define (this config is built into the container):
  - `WORK_PATH`: Path to data config
  - `LOGGER_IP` and `LOGGER_PORT`: IP and port of the logger (graphite)

### Commands

#### Startup

- `make init`: Starts docker swarm, creates required directories and generates the required keys.
- `make build` will build the docker images.

#### Run

- `make deploy` will deploy the system. To execute the system:
  - Run `make manager_bash` to open a bash session on the manager. (Can fail if the container is not ready yet)
  - Run `julia manager.jl` on the manager to start the grid search.
- `make remove` removes all services.

### Monitoring

- Grafana: [http://127.0.0.1:8081](http://127.0.0.1:8081)
- Graphite: [http://127.0.0.1:8080](http://127.0.0.1:8080)
- Logs

## Libraries

- [StatsdClient](https://github.com/glenn-m/Statsd.jl/blob/38ad7bb0b6b40af3ea711e4efc506072a99b32a7/src/Statsd.jl)
- ProgressMeter
