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
    var is_package = false;

    // Parse Java-specific arguments
    if (remaining_args.len > 0) {
        if (std.mem.eql(u8, remaining_args[0], "-p")) {
            if (remaining_args.len > 1) {
                output_dir = remaining_args[1];
                is_package = true;
            } else {
                std.debug.print("Error: Package path not provided after -p flag\n", .{});
                return error.MissingPackagePath;
            }
        } else {
            output_dir = remaining_args[0];
        }
    }

    // Extract class name without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const class_name = filename[0..dot_index];

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");

    var full_class_name: []const u8 = class_name;

    if (is_package) {
        if (output_dir) |dir| {
            // Ensure valid package directory
            if (dir.len == 0) {
                std.debug.print("Error: Invalid package directory\n", .{});
                return error.InvalidArgument;
            }

            // Normalize directory (remove "./" if present)
            const clean_dir = if (std.mem.startsWith(u8, dir, "./")) dir[2..] else dir;

            // Find the base directory (first component of path)
            const split_index = std.mem.indexOfScalar(u8, clean_dir, '/');
            if (split_index == null) {
                std.debug.print("Error: Package structure incorrect\n", .{});
                return error.InvalidArgument;
            }

            // Base directory (root classpath) → first directory
            const base_dir = clean_dir[0..split_index.?];

            // Extract package name (rest of the path)
            const package_path = clean_dir[split_index.? + 1 ..];
            const package_name = try std.mem.replaceOwned(u8, allocator, package_path, "/", ".");

            // Construct fully qualified class name
            full_class_name = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ package_name, class_name });

            // Add Java execution arguments
            try args.append("-cp");
            try args.append(base_dir);
            try args.append(full_class_name);
        }
    } else if (output_dir) |dir| {
        try args.append("-cp");
        try args.append(dir);
        try args.append(class_name);
    } else {
        try args.append(class_name);
    }

    const cmd = try std.mem.join(allocator, " ", args.items);

    // Run Java process safely
    try utils.executeCommand(allocator, args.items);

    allocator.free(cmd);
}