const std = @import("std");

pub fn compileGo(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("go");
    try args.append("build");
    try args.append("-o");

    if (output_dir) |dir| {
        try args.append(dir);
    } else {
        try args.append(".");
    }

    try args.append(file);

    // Spawn the process
    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}