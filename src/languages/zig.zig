const std = @import("std");

pub fn compileZig(file: []const u8, output_path: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("build-exe");
    try args.append(file);

    const emit_arg = try std.fmt.allocPrint(allocator, "-femit-bin={s}", .{output_path});
    defer allocator.free(emit_arg);
    try args.append(emit_arg);

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}

pub fn runZig(file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("run");
    try args.append(file);

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}
