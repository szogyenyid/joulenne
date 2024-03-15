# Joulenne

Joulenne is a simple turbostat-based energy consumption monitoring tool.

## The purpose of Joulenne

Joulenne aims to provide a simple yet effective method for monitoring energy usage on Linux systems using turbostat. It's particularly useful for understanding the energy consumption of various tasks and processes, aiding in optimization and efficiency efforts.

## Intallation

To run Joulenne, you just have to download the shell script (`joulenne.sh`), and run it.

### Dependencies

Joulenne relies on the following dependencies:

1. turbostat: A Linux command-line utility used to monitor CPU and system energy usage. It must be installed and available in your system's PATH for Joulenne to function properly.

Make sure to install turbostat and ensure it's accessible in your system's PATH before using Joulenne.

## Usage

### Options

Joulenne provides the following command-line options:

- --csv: Output the results in CSV format.
- --cycles COUNT: Specify the number of cycles (default: 1).
- --interval SECONDS: Specify the interval in seconds (default: 15).
- --runner COMMAND: Specify the command for executing the test files.
- --test-dir DIRECTORY: Specify the directory containing the test files.
- --verbose: Enable verbose mode.
- --help: Display the help message.

Make use of these options to customize Joulenne according to your requirements.

### Writing good tests

To get accurate energy consumption measurements, it's essential to write effective test scripts. Ensure that your test scripts:

- perform the desired task or workload that you want to measure.
- run continuously until a SIGINT is received.
- are well-structured and do not introduce unnecessary overhead.
- are located in the specified test directory.
- can be compared with each other, so the results can be interpreted effectively.

## License

This tool is open-source and distributed under the [MIT License](LICENSE).