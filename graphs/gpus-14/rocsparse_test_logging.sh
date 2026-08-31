#!/usr/bin/env bash

set -Eeuo pipefail

readonly RELEASE_DIR="/home/netherquark/Soham/Large_code/sources/GPU/rocSPARSE/build/release"
readonly BINARY="/home/netherquark/Soham/Large_code/sources/GPU/rocSPARSE/build/release/clients/staging/rocsparse-test"

readonly STDOUT_FILE="/home/netherquark/Soham/Large_code/sources/GPU/rocSPARSE/build/release/rocsparse-test.stdout"
readonly STDERR_FILE="/home/netherquark/Soham/Large_code/sources/GPU/rocSPARSE/build/release/rocsparse-test.stderr"
readonly LOG_FILE="/home/netherquark/Soham/Large_code/sources/GPU/rocSPARSE/build/release/rocsparse-test.log"

if [[ ! -x "$BINARY" ]]; then
    printf 'ERROR: rocsparse-test is missing or not executable:\n%s\n' "$BINARY" >&2
    exit 1
fi

# Start with empty stream logs for this run.
: > "$STDOUT_FILE"
: > "$STDERR_FILE"

printf 'Starting rocsparse-test\n'
printf 'Binary: %s\n' "$BINARY"
printf 'stdout: %s\n' "$STDOUT_FILE"
printf 'stderr: %s\n' "$STDERR_FILE"

# Run from the release directory so rocsparse-test sees the same
# working directory as when launched manually from build/release.
cd "$RELEASE_DIR"

set +e
"$BINARY" > "$STDOUT_FILE" 2> "$STDERR_FILE"
EXIT_CODE=$?
set -e

# Construct the combined log only after rocsparse-test exits normally.
{
    printf '=== rocsparse-test ===\n'
    printf '=== EXIT CODE: %d ===\n' "$EXIT_CODE"
    printf '\n=== STDOUT ===\n'
    cat "$STDOUT_FILE"
    printf '\n=== STDERR ===\n'
    cat "$STDERR_FILE"
} > "$LOG_FILE"

printf 'rocsparse-test exited with code %d\n' "$EXIT_CODE"

exit "$EXIT_CODE"
