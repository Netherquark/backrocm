#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly BUILD_DIR="${HOME}/Soham/Large_code/sources/GPU/rocm-examples/build/bin/"
readonly OUTPUT_CSV="benchmark_results.csv"
readonly LOG_DIR="./error_logs"

mkdir -p -- "$LOG_DIR"

if [[ ! -d "$BUILD_DIR" ]]; then
    printf 'ERROR: Build directory does not exist: %s\n' "$BUILD_DIR" >&2
    exit 1
fi

if ! command -v find >/dev/null 2>&1; then
    printf 'ERROR: find is required.\n' >&2
    exit 1
fi

if ! command -v date >/dev/null 2>&1; then
    printf 'ERROR: date is required.\n' >&2
    exit 1
fi

###############################################################################
# CSV initialization
###############################################################################

if [[ ! -e "$OUTPUT_CSV" ]]; then
    printf '%s\n' \
        'binary|status|execution_time_ms|error_category|raw_error' \
        > "$OUTPUT_CSV"
elif [[ ! -f "$OUTPUT_CSV" ]]; then
    printf 'ERROR: %s exists but is not a regular file.\n' "$OUTPUT_CSV" >&2
    exit 1
fi

###############################################################################
# Read already-recorded binaries.
#
# The first field is the binary name. This deliberately ignores the other
# fields because the presence of a row means that benchmark has already been
# executed.
###############################################################################

declare -A RECORDED=()

while IFS='|' read -r BINARY _STATUS _TIME _ERROR _RAW; do
    [[ "$BINARY" == "binary" ]] && continue
    [[ -z "$BINARY" ]] && continue

    RECORDED["$BINARY"]=1
done < "$OUTPUT_CSV"

###############################################################################
# Discover executable benchmark binaries.
###############################################################################

mapfile -d '' -t BINARIES < <(
    find "$BUILD_DIR" \
        -type f \
        -perm -u+x \
        -print0
)

if (( ${#BINARIES[@]} == 0 )); then
    printf 'ERROR: No executable binaries found under:\n%s\n' "$BUILD_DIR" >&2
    exit 1
fi

TOTAL_COUNT=${#BINARIES[@]}
SKIP_COUNT=0
RUN_COUNT=0
SUCCESS_COUNT=0
FAILURE_COUNT=0

printf '%s\n' '=== ROCm benchmark runner ==='
printf 'Build directory : %s\n' "$BUILD_DIR"
printf 'Results file    : %s\n' "$OUTPUT_CSV"
printf 'Already recorded: %d\n' "${#RECORDED[@]}"
printf 'Discovered      : %d\n' "$TOTAL_COUNT"
printf '%s\n' '------------------------------------------------'

###############################################################################
# Execute only benchmarks absent from the CSV.
###############################################################################

for BINARY_PATH in "${BINARIES[@]}"; do
    BINARY_NAME=$(basename -- "$BINARY_PATH")

    if [[ -n "${RECORDED[$BINARY_NAME]+x}" ]]; then
        printf '[SKIP] %s (already recorded)\n' "$BINARY_NAME"
        ((SKIP_COUNT += 1))
        continue
    fi

    SAFE_NAME=${BINARY_NAME//[^[:alnum:]._-]/_}
    STDERR_FILE="${LOG_DIR}/${SAFE_NAME}.stderr"

    printf '[RUN ] %s... ' "$BINARY_NAME"

    START_TIME=$(date +%s%N)

    set +e
    "$BINARY_PATH" >/dev/null 2> "$STDERR_FILE"
    EXIT_CODE=$?
    set -e

    END_TIME=$(date +%s%N)
    ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

    STATUS="Success"
    ERROR_CAT="None"
    RAW_ERR_SAMPLE=""

    if (( EXIT_CODE != 0 )); then
        STATUS="Failure"

        RAW_ERR_SAMPLE=$(
            head -n 1 -- "$STDERR_FILE" |
                tr '\n\r|' '   ' |
                sed 's/[[:space:]]*$//'
        )

        #######################################################################
        # Error classification
        #######################################################################

        if grep -Eqi \
            'invalid device function|hipErrorInvalidDeviceFunction|Illegal seek for GPU arch' \
            "$STDERR_FILE"; then

            ERROR_CAT='Runtime Error: "Invalid Device Function"'

        elif grep -Eqi \
            'TensileLibrary|TensileLibrary\.dat|Missing Tensile' \
            "$STDERR_FILE"; then

            ERROR_CAT='Tensile Error: "Missing TensileLibrary.dat"'

        elif grep -Eqi \
            'hipErrorNoDevice|no ROCm-capable device is detected|no device' \
            "$STDERR_FILE"; then

            ERROR_CAT='Initialization Error: "No GPU Device Found"'

        elif grep -Eqi \
            'rocsparse_status_internal_error' \
            "$STDERR_FILE"; then

            ERROR_CAT='rocSPARSE Error: "Internal Error"'

        elif grep -Eqi \
            'rocfft_status_failure' \
            "$STDERR_FILE"; then

            ERROR_CAT='rocFFT Error: "Failure"'

        elif grep -Eqi \
            'terminate called after throwing|uncaught exception|std::exception' \
            "$STDERR_FILE"; then

            ERROR_CAT='Runtime Error: "Unhandled C++ Exception"'

        elif (( EXIT_CODE >= 128 )); then
            SIGNAL=$((EXIT_CODE - 128))
            ERROR_CAT="Process Error: \"Terminated by Signal ${SIGNAL}\""

        else
            ERROR_CAT="Generic Error: \"Non-Zero Exit Code (${EXIT_CODE})\""
        fi
    fi

    ###########################################################################
    # Remove empty stderr files.
    ###########################################################################

    if [[ ! -s "$STDERR_FILE" ]]; then
        rm -f -- "$STDERR_FILE"
    fi

    ###########################################################################
    # Append result immediately.
    #
    # This is intentional. If the machine loses power or the next benchmark
    # crashes the harness, every completed benchmark remains recorded.
    ###########################################################################

    printf '%s|%s|%s|%s|%s\n' \
        "$BINARY_NAME" \
        "$STATUS" \
        "$ELAPSED_MS" \
        "$ERROR_CAT" \
        "$RAW_ERR_SAMPLE" \
        >> "$OUTPUT_CSV"

    # Mark it recorded in this process as well.
    RECORDED["$BINARY_NAME"]=1

    ((RUN_COUNT += 1))

    if [[ "$STATUS" == "Success" ]]; then
        ((SUCCESS_COUNT += 1))
    else
        ((FAILURE_COUNT += 1))
    fi

    printf '[%s] %sms\n' "$STATUS" "$ELAPSED_MS"
done

###############################################################################
# Summary
###############################################################################

printf '%s\n' '------------------------------------------------'
printf '%s\n' 'Suite Execution Complete'
printf 'Discovered : %d\n' "$TOTAL_COUNT"
printf 'Skipped    : %d\n' "$SKIP_COUNT"
printf 'Executed   : %d\n' "$RUN_COUNT"
printf 'Succeeded  : %d\n' "$SUCCESS_COUNT"
printf 'Failed     : %d\n' "$FAILURE_COUNT"
printf 'Results    : %s\n' "$OUTPUT_CSV"
printf 'Error logs : %s\n' "$LOG_DIR"
