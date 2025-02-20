const std = @import("std");
const compiler = @import("compiler.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: grynz build <file> [--out <output_dir>]\n", .{});
        return;
    }

    const command = args[1];
    const file = args[2];
    var output_dir: ?[]const u8 = null;

    if (args.len > 4 and std.mem.eql(u8, args[3], "--out")) {
        output_dir = args[4];
    }

    if (std.mem.eql(u8, command, "build")) {
        try compiler.handleBuild(file, output_dir);
    } else if (std.mem.eql(u8, command, "run")) {
        try compiler.handleRun(file, args[3..]);
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
    }
}