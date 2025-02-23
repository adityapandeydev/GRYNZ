const std = @import("std");
const utils = @import("../utils.zig");

pub fn runElixir(file: []const u8, remaining_args: []const []const u8) !void {
    const allocator = std.heap.page_allocator;

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    // Use the `elixir` command to run the file
    try args.append("elixir");
    try args.append(file);

    // Add any remaining arguments
    for (remaining_args) |arg| {
        try args.append(arg);
    }

    // Spawn the process
    try utils.executeCommand(allocator, args.items);
}