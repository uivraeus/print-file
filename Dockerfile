# Build stage using Zig
FROM ziglings/ziglang:0.12.0 AS builder

WORKDIR /src
COPY build.zig ./
COPY src ./src

RUN zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall

# Final distro-less / scratch image
FROM scratch

COPY --from=builder /src/zig-out/bin/print-file /print-file

ENTRYPOINT ["/print-file"]
