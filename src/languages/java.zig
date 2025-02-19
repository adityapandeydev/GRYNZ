const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileJava(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("javac");

    if (output_dir) |dir| {
        try args.append("-d");
        try args.append(dir);
    }

    try args.append(file);

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    if (result.stderr.len > 0) {
        std.debug.print("Java Compilation Errors:\n{s}\n", .{result.stderr});
    } else {
        std.debug.print("Java Compiled Successfully: {s} → {s}/\n", .{ file, output_dir orelse "current directory" });
    }
}

pub fn runJava(file: []const u8, output_dir: ?[]const u8, is_package: bool) !void {
    const allocator = std.heap.page_allocator;

    // Extract filename without extension
    const filename_start = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
    const filename_no_ext = filename_start[0..dot_index];

    // First check if file exists in current directory
    if (!utils.fileExists(file) and output_dir != null) {
        // If not in current directory, check in output directory
        const class_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ output_dir.?, file });
        defer allocator.free(class_path);

        if (!utils.fileExists(class_path)) {
            std.debug.print("Error: File {s} does not exist in directory {s}\n", .{ file, output_dir.? });
            return error.FileNotFound;
        }
    }

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");

    if (output_dir) |dir| {
        try args.append("-cp");
        if (is_package) {
            if (std.fs.path.dirname(dir)) |parent_dir| {
                try args.append(parent_dir);
                const package_name = std.fs.path.basename(dir);
                const full_class_name = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ package_name, filename_no_ext });
                try args.append(full_class_name);
            }
        } else {
            try args.append(dir);
            try args.append(filename_no_ext);
        }
    } else {
        try args.append(filename_no_ext);
    }

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    if (result.stdout.len > 0) {
        std.debug.print("{s}", .{result.stdout});
    }
    if (result.stderr.len > 0) {
        std.debug.print("Runtime Errors:\n{s}\n", .{result.stderr});
    }
}
