const std = @import("std");
const builtin = @import("builtin");
const c = @import("languages/c.zig");
const cpp = @import("languages/cpp.zig");
const go = @import("languages/go.zig");
const java = @import("languages/java.zig");
const rust = @import("languages/rust.zig");
const zigc = @import("languages/zig.zig");

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

    if (std.mem.eql(u8, command, "build")) {
        // Handle build command flags
        if (args.len > 4 and std.mem.eql(u8, args[3], "--out")) {
            output_dir = args[4];
        }
        try handleBuild(file, output_dir);
    } else if (std.mem.eql(u8, command, "run")) {
        if (std.mem.endsWith(u8, file, ".class")) {
            try java.runJava(file, args[3..]);
        } else if (std.mem.endsWith(u8, file, ".zig")) {
            try zigc.runZig(file);
        } else {
            std.debug.print("Unsupported file type for run command: {s}\n", .{file});
            return;
        }
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
    }
}

fn handleBuild(file: []const u8, output_dir: ?[]const u8) !void {
    // Create output directory if it doesn't exist
    if (output_dir) |dir| {
        std.fs.cwd().makeDir(dir) catch |err| {
            if (err != error.PathAlreadyExists) {
                return err;
            }
        };
    }

    if (std.mem.endsWith(u8, file, ".c")) {
        try c.compileC(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".cpp")) {
        try cpp.compileCpp(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".go")) {
        try go.compileGo(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".java")) {
        try java.compileJava(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".rs")) {
        try rust.compileRust(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.compileZig(file, output_dir);
    } else {
        std.debug.print("Unsupported file type: {s}\n", .{file});
        return;
    }
}