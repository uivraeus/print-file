#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-print-file:latest}"

echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" .
echo "Build complete."
echo ""
echo "--- Image & Binary Info ---"
docker images "${IMAGE_NAME}" --format "Image Size: {{.Size}}"
docker run --rm "${IMAGE_NAME}" --version 2>/dev/null || true
BINARY_SIZE=$(docker run --rm --entrypoint /bin/sh ziglings/ziglang:0.12.0 -c "ls -lh /src/zig-out/bin/print-file 2>/dev/null" || true)
if [ -f "zig-out/bin/print-file" ]; then
    echo "Local Binary Size: $(ls -lh zig-out/bin/print-file | awk '{print $5}') ($(stat -c %s zig-out/bin/print-file) bytes)"
fi
