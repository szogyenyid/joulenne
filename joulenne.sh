#!/bin/bash

## Configuration

### Default values

INTERVAL=15 # seconds
CYCLES=1
VERBOSE=false

### Parse command-line options

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --interval) INTERVAL="$2"; shift ;;
    --cycles) CYCLES="$2"; shift ;;
    --test-dir) TEST_DIR="$2"; shift ;;
    --runner) RUNNER="$2"; shift ;;
    --verbose) VERBOSE=true ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

### Check if script can run

EXIT=0

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   EXIT=1
fi

if [[ -z "$RUNNER" ]]; then
  echo "Error: runner is not specified."
  EXIT=1
fi

if [[ -z "$TEST_DIR" ]]; then
  echo "Error: test directory is not specified."
  EXIT=1
fi

if [[ $EXIT -eq 1 ]]; then
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
  if [ "$VERBOSE" = true ]; then
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
echo "Expected finish: $END_TIME"

### Measure idle energy usage

print_message "Measuring system idle energy usage (${RUNNING_TIME}s)"
output=$(timeout $TIMEOUT bash -c "sudo turbostat --Summary --quiet --Joules --show Pkg_J --interval ${INTERVAL};")
result=$(calculate_average "$output")
TEST_NAMES+=("sys")
TEST_RESULTS+=($result)

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
print_message ""

for ((i=0; i<${#TEST_RESULTS[@]}; i++)); do
  echo "${TEST_NAMES[i]}: ${TEST_RESULTS[i]} Joules"
done