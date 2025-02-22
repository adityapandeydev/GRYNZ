const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileJava(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("javac");
    try args.append(file);

    if (output_dir) |dir| {
        try args.append("-d");
        try args.append(dir);
    }

    try utils.executeCommand(allocator, args.items);
}

pub fn runJava(file: []const u8, remaining_args: []const []const u8) !void {
    const allocator = std.heap.page_allocator;
    var output_dir: ?[]const u8 = null;

    // Parse --out flag if present
    if (remaining_args.len > 1 and std.mem.eql(u8, remaining_args[0], "--out")) {
        output_dir = remaining_args[1];
    }

    // Extract class name without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const class_name = filename[0..dot_index];

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");

    if (output_dir) |dir| {
        try args.append("-cp");
        try args.append(dir);
    }

    try args.append(class_name);

    // Run Java process
    try utils.executeCommand(allocator, args.items);
}