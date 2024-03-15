# Joulenne

Joulenne is a simple turbostat-based energy consumption measurement tool.

## The purpose of Joulenne

Joulenne aims to provide a simple yet effective method for measuring energy usage of different processes on Linux systems using turbostat. It's particularly useful for understanding the energy consumption of various tasks and processes, aiding in optimization and efficiency efforts.

## Intallation

To run Joulenne, you just have to download the shell script (`joulenne.sh`), and run it.

### Dependencies

Joulenne relies on the following dependencies:

1. turbostat: A Linux command-line utility used to monitor CPU and system energy usage. It must be installed and available in your system's PATH for Joulenne to function properly.

Make sure to install turbostat and ensure it's accessible in your system's PATH before using Joulenne.

## Usage

### Example

To measure the provided PHP example scripts, you should use the following command:

```bash
sudo ./joulenne.sh --runner php --test-dir examples/php/increment
```

#### Specifying measurement time

You can use two options to modify the running time of a measurement:

1. `--interval`: determines how many seconds in the past should turbostat get the consumed energy for
1. `--cycles`: determines how many times the interval is ran

The test runs for a sum of `(# of tests + 1) * (interval * cycles + 1)` seconds.

So if you want your tests to run for 60 seconds each, and you would like to get a sample of energy usage every 10 seconds, the following flags are needed: 

```bash
sudo ./joulenne.sh (...) --interval 10 --cycles 6
```

The results will return the average energy consumption of cycles (each cycle taking interval seconds).

#### Exporting to CSV

You can import the results directly to CSV, to do so, just use the `--csv` flag and redirect the output to a file, eg.:

```bash
sudo ./joulenne.sh (...) --csv > output.csv
```

### Options

Joulenne provides the following command-line options:

- `--csv`: Output the results in CSV format.
- `--cycles COUNT`: Specify the number of cycles (default: 1).
- `--interval SECONDS`: Specify the interval in seconds (default: 15).
- `--nosys`: Skip the measurement of idle energy consumption.
- `--runner COMMAND`: Specify the command for executing the test files.
- `--test-dir DIRECTORY`: Specify the directory containing the test files.
- `--verbose`: Enable verbose mode.
- `--help`: Display the help message.

Make use of these options to customize Joulenne according to your requirements.

### Writing good tests

To get accurate energy consumption measurements, it's essential to write effective test scripts. Ensure that your test scripts:

- perform the desired task or workload that you want to measure.
- run continuously until a SIGINT is received.
- are well-structured and do not introduce unnecessary overhead.
- are located in the specified test directory.
- can be compared with each other, so the results can be interpreted effectively.

### Important notes

#### On turbostat and accuracy

Turbostat cannot measure the energy consumption of a single process, it just gives a status about the whole CPU. To make measurements as accurate as possible, try to keep the CPU usage at a constant level. It's inevitable to have noise in the data, but having a constant noise, and choosing ideal values for interval and cycle can minimuze the error of the measurement.

#### On the actual numbers

Joulenne is not intented to determine the actual energy consumption of complex applications. It's original purpose is identifying coding best practices from an energy-efficiency point of view. The actual energy consumption may vary from hardware to hardware, the goal of Joulenne is comparison of processes on the same host. 

## License

This tool is open-source and distributed under the [MIT License](LICENSE).