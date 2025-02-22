const std = @import("std");
const builtin = @import("builtin");
const utils = @import("../utils.zig");

pub fn compileKotlin(file: []const u8, output_dir: ?[]const u8, include_runtime: bool) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("kotlinc");
    try args.append(file);

    // Add -include-runtime flag if specified
    if (include_runtime) {
        try args.append("-include-runtime");
    }

    // Determine the output JAR path
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];
    const jar_name = try std.mem.concat(allocator, u8, &.{ name, ".jar" });

    var final_output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        final_output_path = try std.fs.path.join(allocator, &.{ dir, jar_name });
    } else {
        final_output_path = jar_name;
    }

    // Add the output argument
    const output_arg = try std.mem.concat(allocator, u8, &.{ "-d=", final_output_path });
    try args.append(output_arg);

    // Execute the command
    try utils.executeCommand(allocator, args.items);

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(jar_name);
    allocator.free(output_arg);
}

pub fn runKotlin(jar_file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");
    try args.append("-jar");
    try args.append(jar_file);

    // Execute the command
    try utils.executeCommand(allocator, args.items);
}