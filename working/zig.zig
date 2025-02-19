const std = @import("std");

pub fn compileZig(file: []const u8, output_path: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("build-exe");
    try args.append(file);

    const emit_arg = try std.fmt.allocPrint(allocator, "-femit-bin={s}", .{output_path});
    defer allocator.free(emit_arg);
    try args.append(emit_arg);

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    if (result.stderr.len > 0) {
        std.debug.print("Zig Compilation Errors:\n{s}\n", .{result.stderr});
    } else {
        std.debug.print("Zig Compiled Successfully: {s} → {s}\n", .{ file, output_path });
    }
}