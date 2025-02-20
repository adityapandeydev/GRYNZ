const std = @import("std");

pub fn executeCommand(allocator: std.mem.Allocator, args: []const []const u8) !void {
    var child = std.process.Child.init(args, allocator);
    child.stderr_behavior = .Inherit; // Keep error output visible
    try child.spawn();
    _ = try child.wait();
}