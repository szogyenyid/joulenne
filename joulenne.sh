#!/bin/bash

## Configuration

### Default values

INTERVAL=15 # seconds
CYCLES=1
NO_SYS=false
VERBOSE=false
CSV=false
EXIT=0

### Add help contents
print_usage() {
    echo "Usage: $0 [--interval SECONDS] [--cycles COUNT] [--test-dir DIRECTORY] [--runner COMMAND] [--nosys] [--csv] [--verbose] [--help]"
    echo "Options:"
    echo "  --csv                  Output in CSV format"
    echo "  --cycles COUNT         Specify the number of cycles (default: 1)"
    echo "  --interval SECONDS     Specify the interval in seconds (default: 15)"
    echo "  --nosys                Skip the measurement of system idle energy"
    echo "  --runner COMMAND       Specify the runner command"
    echo "  --test-dir DIRECTORY   Specify the test directory"
    echo "  --verbose              Enable verbose mode"
    echo "  --help                 Display this help message and exit"
}

### Parse command-line options

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help) print_usage; exit 0 ;; # Print usage instructions and exit
    --csv) CSV=true ;;
    --cycles) CYCLES="$2"; shift ;;
    --interval) INTERVAL="$2"; shift ;;
    --nosys) NO_SYS=true ;;
    --runner) RUNNER="$2"; shift ;;
    --test-dir) TEST_DIR="$2"; shift ;;
    --verbose) VERBOSE=true ;;
    *) echo "Error: unknown option: $1"; EXIT=1 ;;
  esac
  shift
done

### Check if script can run

if ! command -v turbostat &> /dev/null; then
    echo "Error: turbostat could not be found. To use Joulenne, please install turbostat and add it to your PATH."
    EXIT=1
fi

if ! [ $(id -u) = 0 ]; then
   echo "Error: the script need to be run as root." >&2
   EXIT=1
fi

if [[ -z "$RUNNER" ]]; then
  echo "Error: runner is not specified. Please use --runner to specify one."
  EXIT=1
fi

if [[ -z "$TEST_DIR" ]]; then
  echo "Error: test directory is not specified. Please use --test-dir to specify one."
  EXIT=1
fi

if [[ $EXIT -eq 1 ]]; then
    echo "Use --help to see the help page."; 
    exit 1
fi

## Preprocessing

RUNNING_TIME=$((INTERVAL * CYCLES))
TIMEOUT_S=$((RUNNING_TIME + 1))
TIMEOUT="${TIMEOUT_S}s"
TEST_PATH="$(pwd)/${TEST_DIR}"

TEST_NAMES=()
TEST_RESULTS=()

print_message() {
  if [[ "$VERBOSE" = true && "$CSV" = false ]]; then
    echo "$1"
  fi
}

calculate_average() {
    local output="$1"
    local sum=0
    local count=0
    local skip_first_line=true

    while IFS= read -r line; do
        if [ "$skip_first_line" = true ]; then
            skip_first_line=false
            continue
        fi

        if [[ "$line" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then
            value_in_cents=$(echo "$line" | tr -d '.' | awk '{printf "%.0f", $1}')
            sum=$((sum + value_in_cents))
            ((count++))
        fi
    done <<< "$output"

    if [ "$count" -gt 0 ]; then
        average_in_cents=$((sum / count))
        length=${#average_in_cents}
        before_dot="${average_in_cents:0:($length-2)}"
        after_dot="${average_in_cents:($length-2)}"
        result="${before_dot}.${after_dot}"
        echo "$result"
    else
        echo "No valid numeric values found."
    fi
}

## Run the benchmark

### Get expected end time
NUM_FILES=$(find "$TEST_PATH" -maxdepth 1 -type f | wc -l)
NUM_TESTS=$((NUM_FILES + 1))
SUM_TIME=$((NUM_TESTS * TIMEOUT_S))

END_TIME=$(date -d "+$SUM_TIME seconds" +"%Y-%m-%d %H:%M:%S")
if [ "$CSV" = false ]; then
    echo "Expected finish: $END_TIME"
fi

### Measure idle energy usage

if [ "$NO_SYS" = false ]; then
    print_message "Measuring system idle energy usage (${RUNNING_TIME}s)"
    output=$(timeout $TIMEOUT bash -c "sudo turbostat --Summary --quiet --Joules --show Pkg_J --interval ${INTERVAL};")
    result=$(calculate_average "$output")
    TEST_NAMES+=("sys")
    TEST_RESULTS+=($result)
fi

### Measure energy usage of test files

for filename in $TEST_PATH/*; do
    basefilename=$(basename "$filename")
    filename_no_extension="${basefilename%.*}"
    print_message "Measuring energy usage for test: $filename_no_extension (${RUNNING_TIME}s)"
    output=$(timeout $TIMEOUT bash -c "${RUNNER} ${filename} & sudo turbostat --Summary --quiet --Joules --show Pkg_J --interval ${INTERVAL};")
    result=$(calculate_average "$output")
    TEST_NAMES+=($filename_no_extension)
    TEST_RESULTS+=($result)
done

## Calculate and output results

print_message ""

if [ "$CSV" = true ]; then
    echo "Test,Energy usage (Joules)"
    for ((i=0; i<${#TEST_RESULTS[@]}; i++)); do
        echo "${TEST_NAMES[i]},${TEST_RESULTS[i]}"
    done
else 
    for ((i=0; i<${#TEST_RESULTS[@]}; i++)); do
        echo "${TEST_NAMES[i]}: ${TEST_RESULTS[i]} Joules"
    done
fi