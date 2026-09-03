const std = @import("std");

pub fn main() !void {
    const args = std.os.argv;

    if (args.len != 2) {
        const stderr = std.io.getStdErr().writer();
        _ = stderr.writeAll("Error: Expected exactly one file path argument\nUsage: print-file <absolute-path>\n") catch {};
        std.process.exit(1);
    }

    const path = std.mem.span(args[1]);

    if (path.len == 0 or path[0] != '/') {
        const stderr = std.io.getStdErr().writer();
        _ = stderr.print("Error: Path must be an absolute path starting with '/': {s}\n", .{path}) catch {};
        std.process.exit(1);
    }

    const stderr = std.io.getStdErr().writer();

    const file = std.fs.openFileAbsolute(path, .{}) catch {
        _ = stderr.print("Error: Could not open file: {s}\n", .{path}) catch {};
        std.process.exit(1);
    };
    defer file.close();

    var buffer: [8192]u8 = undefined;
    const stdout = std.io.getStdOut().writer();

    while (true) {
        const bytes_read = file.read(&buffer) catch {
            _ = stderr.print("Error: Could not open file: {s}\n", .{path}) catch {};
            std.process.exit(1);
        };
        if (bytes_read == 0) break;

        stdout.writeAll(buffer[0..bytes_read]) catch |err| {
            _ = stderr.print("Error: Failed to write output: {s}\n", .{@errorName(err)}) catch {};
            std.process.exit(1);
        };
    }
}
