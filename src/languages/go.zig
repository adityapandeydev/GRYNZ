const std = @import("std");

pub fn compileGo(file: []const u8, output_path: []const u8) !void {
    var args = [_][]const u8{ "go", "build", "-o", output_path, file };

    const result = try std.process.Child.run(.{
        .allocator = std.heap.page_allocator,
        .argv = &args,
        .cwd = null,
        .env_map = null,
    });

    if (result.stderr.len > 0) {
        std.debug.print("Go Compilation Errors:\n{s}\n", .{result.stderr});
    } else {
        std.debug.print("Go Compiled Successfully: {s} → {s}\n", .{file, output_path});
    }
}