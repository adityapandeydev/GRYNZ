const std = @import("std");

pub fn fileExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch |err| {
        return switch (err) {
            error.FileNotFound => false,
            else => true,
        };
    };
    return true;
}