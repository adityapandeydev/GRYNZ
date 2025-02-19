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

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}

pub fn runJava(file: []const u8, output_dir: ?[]const u8, is_package: bool) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("java");

    if (output_dir) |dir| {
        try args.append("-cp");
        if (is_package) {
            if (std.fs.path.dirname(dir)) |parent_dir| {
                try args.append(parent_dir);
                const package_name = std.fs.path.basename(dir);
                const filename_start = std.fs.path.basename(file);
                const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
                const filename_no_ext = filename_start[0..dot_index];
                const full_class_name = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ package_name, filename_no_ext });
                try args.append(full_class_name);
            }
        } else {
            try args.append(dir);
            const filename_start = std.fs.path.basename(file);
            const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
            const filename_no_ext = filename_start[0..dot_index];
            try args.append(filename_no_ext);
        }
    } else {
        const filename_start = std.fs.path.basename(file);
        const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
        const filename_no_ext = filename_start[0..dot_index];
        try args.append(filename_no_ext);
    }

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}
