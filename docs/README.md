# Benchmarks

## Measurements

### FaMAF Server

| Measurement         | 4 Nodes             | 8 Nodes             | 16 Nodes            |
|---------------------|---------------------|---------------------|---------------------|
| Worker Throughput   | 1.36 Results/Second | 1.28 Results/Second | 1.26 Results/Second |
| Combined Throughput | 5.43 Results/Second | 10.1 Results/Second | 20.0 Results/Second |
| Work-time Variation | 1.83%               | 1.21%               | 0.757%              |
| Memory Usage        | 1.24 GB/Worker      | 1.24 GB/Worker      | 1.18 MB/Worker      |
| Network Usage (Tx)  | 327 B/(s * Worker)  | 305 B/(s * Worker)  | 302 B/(s * Worker)  |
| Network Usage (Rx)  | 220 B/(s * Worker)  | 207 B/(s * Worker)  | 206 B/(s * Worker)  |
| CPU Usage           | 100%/Worker         | 100%/Worker         | 100%/Worker         |
| Completion Time     | 73.2 Minutes        | 39.2 Minutes        | 20.0 Minutes        |

### Cloud (GCP)

| Measurement         | 4 Nodes            | 8 Nodes        | 16 Nodes       |
|---------------------|--------------------|----------------|----------------|
| Worker Throughput   | Results/Second     | Results/Second | Results/Second |
| Combined Throughput | Results/Second     | Results/Second | Results/Second |
| Work-time Variation | %                  | %              | %              |
| Memory Usage        | MB/Worker          | MB/Worker      | MB/Worker      |
| Network Usage (Tx)  | 327 B/(s * Worker) | B/(s * Worker) | B/(s * Worker) |
| Network Usage (Rx)  | 220 B/(s * Worker) | B/(s * Worker) | B/(s * Worker) |
| CPU Usage           | %/Worker           | %/Worker       | %/Worker       |
| Completion Time     | Minutes            | Minutes        | Minutes        |

Average measurements using the [specified configuration](measurements/README.md)

## Subjective analysis

TODO