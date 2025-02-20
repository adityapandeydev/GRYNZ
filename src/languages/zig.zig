const std = @import("std");
const builtin = @import("builtin");
const utils = @import("../utils.zig");

pub fn compileZig(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("build-exe");
    try args.append(file);

    // Extract filename without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    // Ensure a correct output path
    var final_output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        final_output_path = try std.fs.path.join(allocator, &.{ dir, name });
    } else {
        final_output_path = name;
    }

    // Ensure `.exe` extension on Windows
    const ext = if (builtin.os.tag == .windows) ".exe" else "";
    const final_output = try std.mem.concat(allocator, u8, &.{ final_output_path, ext });

    const emit_arg = try std.mem.concat(allocator, u8, &.{ "-femit-bin=", final_output });
    try args.append(emit_arg);

    // Spawn the process
    try utils.executeCommand(allocator, args.items);

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(final_output);
    allocator.free(emit_arg);
}

pub fn runZig(file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("run");
    try args.append(file);

    try utils.executeCommand(allocator, args.items);
}