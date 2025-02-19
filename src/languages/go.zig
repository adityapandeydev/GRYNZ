const std = @import("std");

pub fn compileGo(file: []const u8, output_path: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("go");
    try args.append("build");
    try args.append("-o");
    try args.append(output_path);
    try args.append(file);

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}