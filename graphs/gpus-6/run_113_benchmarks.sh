#!/usr/bin/env bash

# Define paths and file targets
OUTPUT_CSV="benchmark_results.csv"
LOG_DIR="./error_logs"
mkdir -p "$LOG_DIR"

# Write CSV header row (Using '|' as a delimiter)
echo "binary|status|execution_time_ms|error_category|raw_error" > "$OUTPUT_CSV"

echo "=== Gathering all valid ROCm example binaries ==="
BINARIES=($(rpm -ql rocm-examples | grep -E '^/usr/bin/'))

echo "Found ${#BINARIES[@]} binaries to execute."
echo "------------------------------------------------"

for BINARY_PATH in "${BINARIES[@]}"; do
    BINARY_NAME=$(basename "$BINARY_PATH")
    echo -n "Running $BINARY_NAME... "
    
    STDERR_FILE="$LOG_DIR/${BINARY_NAME}.stderr"
    START_TIME=$(date +%s%N)
    
    $BINARY_PATH >/dev/null 2> "$STDERR_FILE"
    EXIT_CODE=$?
    
    END_TIME=$(date +%s%N)
    ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))
    
    STATUS="Success"
    ERROR_CAT="None"
    RAW_ERR_SAMPLE=""
    
    if [ $EXIT_CODE -ne 0 ]; then
        STATUS="Failure"
        # Sanitize error output: remove newlines, carriage returns, and pipes
        RAW_ERR_SAMPLE=$(head -n 1 "$STDERR_FILE" | tr -d '\n' | tr -d '\r' | tr '|' '-')
        
        if grep -q -E "invalid device function|Illegal seek for GPU arch" "$STDERR_FILE"; then
            ERROR_CAT="Runtime Error: \"Invalid Device Function\""
        elif grep -q -E "TensileLibrary|Tensile" "$STDERR_FILE"; then
            ERROR_CAT="Tensile Error: \"Missing TensileLibrary.dat\""
        elif grep -q -I "hipErrorNoDevice" "$STDERR_FILE"; then
            ERROR_CAT="Initialization Error: \"No GPU Device Found\""
        else
            ERROR_CAT="Generic Error: \"Non-Zero Exit Code ($EXIT_CODE)\""
        fi
    fi
    
    if [ ! -s "$STDERR_FILE" ]; then
        rm "$STDERR_FILE"
    fi
    
    # Write using pipe delimiters
    echo "${BINARY_NAME}|${STATUS}|${ELAPSED_MS}|${ERROR_CAT}|${RAW_ERR_SAMPLE}" >> "$OUTPUT_CSV"
    echo "[$STATUS] done in ${ELAPSED_MS}ms"
done

echo "------------------------------------------------"
echo "Suite Execution Complete! Structural log saved to: $OUTPUT_CSV"
