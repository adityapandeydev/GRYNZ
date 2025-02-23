const std = @import("std");

pub fn executeCommand(allocator: std.mem.Allocator, args: []const []const u8) !void {
    var child = std.process.Child.init(args, allocator);
    child.stderr_behavior = .Inherit; // Keep error output visible
    try child.spawn();
    _ = try child.wait();
}

pub fn filterOutFlag(allocator: std.mem.Allocator, args: []const []const u8, flag: []const u8) ![]const []const u8 {
    var filtered_args = std.ArrayList([]const u8).init(allocator);
    defer filtered_args.deinit();

    var i: usize = 0;
    while (i < args.len) {
        if (std.mem.eql(u8, args[i], flag)) {
            i += 2; // Skip the flag and its value
        } else {
            try filtered_args.append(args[i]);
            i += 1;
        }
    }

    return filtered_args.toOwnedSlice();
}

pub fn parseOutputDir(remaining_args: []const []const u8) !?[]const u8 {
    var output_dir: ?[]const u8 = null;

    var i: usize = 0;
    while (i < remaining_args.len) {
        if (std.mem.eql(u8, remaining_args[i], "--out")) {
            if (i + 1 < remaining_args.len) {
                output_dir = remaining_args[i + 1];
                i += 2;
            } else {
                std.debug.print("Error: --out requires an output directory\n", .{});
                return error.MissingOutputDir;
            }
        } else {
            i += 1;
        }
    }

    return output_dir;
}