## Measurements

The system was run on the designated server, using the [Griewank function](https://www.sfu.ca/~ssurjano/griewank.html), with 4,8 and 16 nodes; with the following parameters:

```json
{
  "data": [
    [-600, 600, 0.2, 5],
    [-600, 600, 0.2, 5],
    [-600, 600, 0.2, 5]
  ],
  "agg": "MIN",
  "maxItemsPerBatch": 10800000
}
```

### Average Summary

#### FaMAF Server

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

#### Cloud (GCP)

| Measurement         | 4 Nodes             | 8 Nodes             | 16 Nodes            |
|---------------------|---------------------|---------------------|---------------------|
| Worker Throughput   | 1.18 Results/Second | 1.16 Results/Second | 1.18 Results/Second |
| Combined Throughput | 4.69 Results/Second | 9.19 Results/Second | 18.8 Results/Second |
| Work-time Variation | 2.40%               | 1.58%               | 2.19%               |
| Memory Usage        | 1.10 GB/Worker      | 1.08 GB/Worker      | 1.09 GB/Worker      |
| Network Usage (Tx)  | 280 B/(s * Worker)  | 276 B/(s * Worker)  | 282 B/(s * Worker)  |
| Network Usage (Rx)  | 189 B/(s * Worker)  | 187 B/(s * Worker)  | 194 B/(s * Worker)  |
| CPU Usage           | 100%/Worker         | 100%/Worker         | 100%/Worker         |
| Completion Time     | 85.2 Minutes        | 43.3 Minutes        | 21.3 Minutes        |

