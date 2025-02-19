const std = @import("std");

pub fn compileRust(file: []const u8, output_path: []const u8) !void {
    var args = [_][]const u8{ "rustc", file, "-o", output_path };

    const result = try std.process.Child.run(.{
        .allocator = std.heap.page_allocator,
        .argv = &args,
        .cwd = null,
        .env_map = null,
    });

    if (result.stderr.len > 0) {
        std.debug.print("Rust Compilation Errors:\n{s}\n", .{result.stderr});
    } else {
        std.debug.print("Rust Compiled Successfully: {s} → {s}\n", .{file, output_path});
    }
}