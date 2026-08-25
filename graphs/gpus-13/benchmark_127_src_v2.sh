#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

# Standardize path resolution using relative traversal from current execution path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUILD_DIR="${SCRIPT_DIR}/../../../rocm-examples/build/bin"
readonly OUTPUT_CSV="benchmark_results_127_debug.csv"
readonly LOG_DIR="./error_logs_127_debug"

mkdir -p -- "$LOG_DIR"

if [[ ! -d "$BUILD_DIR" ]]; then
    printf 'ERROR: Build directory does not exist: %s\n' "$BUILD_DIR" >&2
    exit 1
fi

###############################################################################
# CSV initialization
###############################################################################

if [[ ! -e "$OUTPUT_CSV" ]]; then
    printf '%s\n' \
        'binary|status|execution_time_ms|error_category|raw_error' \
        > "$OUTPUT_CSV"
fi

declare -A RECORDED=()
while IFS='|' read -r BINARY _STATUS _TIME _ERROR _RAW; do
    [[ "$BINARY" == "binary" || -z "$BINARY" ]] && continue
    RECORDED["$BINARY"]=1
done < "$OUTPUT_CSV"

###############################################################################
# Explicit list of targeted binaries
###############################################################################

TARGET_NAMES=(
    "rocsolver_syev_strided_batched"
    "rocsolver_syev"
    "rocsolver_syev_batched"
    "rocsparse_gpsv"
    "rocsparse_gtsv"
    "rocsparse_csritsv"
    "rocsparse_gebsrmv"
    "rocsparse_ellmv"
    "rocsparse_coomv"
    "rocsparse_gthr"
    "rocsparse_axpyi"
    "rocsparse_sctr"
    "rocsparse_roti"
    "rocsparse_doti"
    "rocsparse_gebsrmm"
    "hipsolver_gels"
    "hipsolver_potrf"
    "hipsolver_syevd"
    "hipsolver_syevj"
)

BINARIES=()
for TARGET in "${TARGET_NAMES[@]}"; do
    # Recursively locate binary anywhere within subdirectories of BUILD_DIR
    FOUND_PATH=$(find "$BUILD_DIR" -type f -name "$TARGET" -executable 2>/dev/null | head -n 1)

    if [[ -n "$FOUND_PATH" ]]; then
        BINARIES+=("$FOUND_PATH")
    else
        printf 'WARNING: Target binary not found or not executable: %s\n' "$TARGET" >&2
    fi
done

if (( ${#BINARIES[@]} == 0 )); then
    printf 'ERROR: None of the target binaries were found under:\n%s\n' "$BUILD_DIR" >&2
    exit 1
fi

printf 'Discovered %d executable targets.\n' "${#BINARIES[@]}"

###############################################################################
# Execution & Debug Logging
###############################################################################

for BINARY_PATH in "${BINARIES[@]}"; do
    BINARY_NAME=$(basename -- "$BINARY_PATH")

    if [[ -n "${RECORDED[$BINARY_NAME]+x}" ]]; then
        printf '[SKIP] %s (already recorded)\n' "$BINARY_NAME"
        continue
    fi

    SAFE_NAME=${BINARY_NAME//[^[:alnum:]._-]/_}
    STDERR_FILE="${LOG_DIR}/${SAFE_NAME}.stderr"
    STDOUT_FILE="${LOG_DIR}/${SAFE_NAME}.stdout"
    COMBINED_LOG="${LOG_DIR}/${SAFE_NAME}.log"

    printf '[RUN ] %s... ' "$BINARY_NAME"
    START_TIME=$(date +%s%N)

    set +e
    AMD_LOG_LEVEL=3 \
    HIP_LAUNCH_BLOCKING=1 \
    ROCM_LOG_LEVEL=3 \
    "$BINARY_PATH" > "$STDOUT_FILE" 2> "$STDERR_FILE"
    EXIT_CODE=$?
    set -e

    END_TIME=$(date +%s%N)
    ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

    {
        printf '=== EXIT CODE: %d ===\n' "$EXIT_CODE"
        printf '=== STDOUT ===\n'
        cat "$STDOUT_FILE"
        printf '\n=== STDERR ===\n'
        cat "$STDERR_FILE"
    } > "$COMBINED_LOG"

    STATUS="Success"
    ERROR_CAT="None"

    if (( EXIT_CODE != 0 )); then
        STATUS="Failure"

        RAW_ERR_SAMPLE=$(
            head -n 2 -- "$COMBINED_LOG" |
                tr '\n\r|' '   ' |
                sed 's/[[:space:]]*$//'
        )

        if grep -Eqi 'Validation failed|does not converge' "$COMBINED_LOG"; then
            ERROR_CAT='Code/Math Error: "Numerical Validation Failed (Custom exit 127)"'
        elif grep -Eqi 'invalid device function|hipErrorNoBinaryInModule' "$COMBINED_LOG"; then
            ERROR_CAT='Compiler Failure: "Missing Target GPU Architecture Code"'
        elif grep -Eqi 'rocsparse_status_arch_mismatch' "$COMBINED_LOG"; then
            ERROR_CAT='Hardware Incompatibility: "Architecture Mismatch"'
        else
            ERROR_CAT="Generic Error: \"Non-Zero Exit Code (${EXIT_CODE})\""
        fi
    fi

    printf '%s|%s|%s|%s|%s\n' \
        "$BINARY_NAME" "$STATUS" "$ELAPSED_MS" "$ERROR_CAT" "${RAW_ERR_SAMPLE:-N/A}" \
        >> "$OUTPUT_CSV"

    printf '[%s] %sms\n' "$STATUS" "$ELAPSED_MS"
done
