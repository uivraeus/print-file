.PHONY: all build docker-build test clean

ZIG_IMAGE ?= ziglings/ziglang:0.12.0
IMAGE_NAME ?= print-file:latest

all: docker-build

# Build static binary using Docker container without local Zig installation
build:
	docker run --rm -v "$$(pwd)":/src -w /src $(ZIG_IMAGE) zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall

# Build scratch OCI image
docker-build:
	docker build -t $(IMAGE_NAME) .

# Run test suite using Docker container
test: docker-build
	@echo "Running tests..."
	@# Test valid file print
	@docker run --rm -v "$$(pwd)/README.md:/README.md" $(IMAGE_NAME) /README.md | grep -q "print-file" && echo "PASS: Valid file print"
	@# Test non-existent file (expect exit code 1)
	@docker run --rm $(IMAGE_NAME) /nonexistent.txt 2>&1 | grep -q "Could not open file" && echo "PASS: Non-existent file error"
	@# Test directory path (expect uniform Could not open file)
	@docker run --rm -v "$$(pwd):/tmp/dir" $(IMAGE_NAME) /tmp/dir 2>&1 | grep -q "Could not open file" && echo "PASS: Directory path uniform error"
	@# Test relative path (expect exit code 1)
	@docker run --rm $(IMAGE_NAME) relative.txt 2>&1 | grep -q "must be an absolute path" && echo "PASS: Relative path error"
	@# Test missing argument (expect exit code 1)
	@docker run --rm --entrypoint /print-file $(IMAGE_NAME) 2>&1 | grep -q "Expected exactly one" && echo "PASS: Missing argument error"
	@echo "All tests passed!"

clean:
	rm -rf zig-cache zig-out
