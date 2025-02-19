const std = @import("std");

pub fn compileC(file: []const u8, output_path: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("gcc");
    try args.append(file);
    try args.append("-o");
    try args.append(output_path);

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}