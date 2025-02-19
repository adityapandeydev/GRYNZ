const std = @import("std");

pub fn compileJava(file: []const u8, output_dir: ?[]const u8) !void {
    var args = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer args.deinit();

    try args.append("javac");

    if (output_dir) |dir| {
        try args.append("-d");
        try args.append(dir);
    }

    try args.append(file);

    const result = try std.process.Child.run(.{
        .allocator = std.heap.page_allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    if (result.stderr.len > 0) {
        std.debug.print("Java Compilation Errors:\n{s}\n", .{result.stderr});
    } else {
        std.debug.print("Java Compiled Successfully: {s} → {s}/\n", .{file, output_dir orelse "current directory"});
    }
}

pub fn runJava(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;

    // Extract filename without extension
    const filename_start = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
    const filename_no_ext = filename_start[0..dot_index];

    var classpath: []const u8 = "./";
    if (output_dir) |dir| {
        classpath = dir;
    }

    // Determine if the file contains a package declaration
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");
    try args.append("-cp");
    try args.append(classpath);
    try args.append(filename_no_ext);

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    if (result.stdout.len > 0) {
        std.debug.print("Program Output:\n{s}\n", .{result.stdout});
    }
    if (result.stderr.len > 0) {
        std.debug.print("Runtime Errors:\n{s}\n", .{result.stderr});
    }
}