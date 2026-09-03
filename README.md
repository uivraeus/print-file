# print-file - too simple?

A very simple and limited tool for printing the content of a file to stdout.

## Why?

The intended use-case is to enable this capability in environments where there is no shell and no standard Linux tooling available, e.g. a "distro-less" or "scratch" container. This include:

* Static linking - don't assume anything about the distro in which it will operate
* Minimal - don't add unnecessary feature and capability to a intentionally reduced/limited system

## What?

The tool takes one argument, the full path file name. It then prints the entire content to stdout.

Nothing more, i.e.:

* No support for printing multiple files
* No support for globbing
* No support for relative paths

Error handling:

* Generic error string on stderr (`Error: Could not open file: <path>`) for all file, directory, or permission access issues.
* Intentionally reduced feedback granularity to prevent using the tool for file discovery, directory structure enumeration, or permission probing.
* Return code: 1 on any error.

## How?

This tool is packaged into an OCI image (without anything else in it). This allows for easy integration into Kubernetes Pods where OCI images can be mounted as Volumes directly.

## Development & Usage (Docker-based)

### Build OCI Image

```bash
./build.sh
# or
docker build -t print-file:latest .
```

### Run Container

```bash
docker run --rm -v "$PWD/README.md:/README.md" print-file:latest /README.md
```

### Run Tests

```bash
./test.sh
```

