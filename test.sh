#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-print-file:latest}"

echo "Building ${IMAGE_NAME}..."
./build.sh "${IMAGE_NAME}"

echo "Running tests..."

# 1. Test printing a valid file
OUTPUT=$(docker run --rm -v "$PWD/README.md:/README.md" "${IMAGE_NAME}" /README.md)
if echo "$OUTPUT" | grep -q "print-file"; then
    echo "✓ Test 1 Passed: Valid file printing"
else
    echo "✗ Test 1 Failed: Valid file content not output properly"
    exit 1
fi

# 2. Test file not found / directory handling
set +e
ERR_OUT=$(docker run --rm "${IMAGE_NAME}" /nonexistent.txt 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 1 ] && echo "$ERR_OUT" | grep -q "Could not open file"; then
    echo "✓ Test 2 Passed: Non-existent file error handling (exit code 1)"
else
    echo "✗ Test 2 Failed: Got exit code $EXIT_CODE, output: $ERR_OUT"
    exit 1
fi

# 3. Test directory error reduced granularity (returns Could not open file)
set +e
ERR_OUT=$(docker run --rm -v "$PWD:/tmp/dir" "${IMAGE_NAME}" /tmp/dir 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 1 ] && echo "$ERR_OUT" | grep -q "Could not open file" && ! echo "$ERR_OUT" | grep -q -i "directory"; then
    echo "✓ Test 3 Passed: Directory path reported uniformly as Could not open file"
else
    echo "✗ Test 3 Failed: Got exit code $EXIT_CODE, output: $ERR_OUT"
    exit 1
fi

# 4. Test relative path rejection
set +e
ERR_OUT=$(docker run --rm "${IMAGE_NAME}" relative/path.txt 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 1 ] && echo "$ERR_OUT" | grep -q "must be an absolute path"; then
    echo "✓ Test 4 Passed: Relative path rejection (exit code 1)"
else
    echo "✗ Test 4 Failed: Got exit code $EXIT_CODE, output: $ERR_OUT"
    exit 1
fi

# 5. Test invalid argument count
set +e
ERR_OUT=$(docker run --rm --entrypoint /print-file "${IMAGE_NAME}" 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 1 ] && echo "$ERR_OUT" | grep -q "Expected exactly one"; then
    echo "✓ Test 5 Passed: Missing argument handling (exit code 1)"
else
    echo "✗ Test 5 Failed: Got exit code $EXIT_CODE, output: $ERR_OUT"
    exit 1
fi

echo "All tests passed successfully!"
