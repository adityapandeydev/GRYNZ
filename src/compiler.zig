const std = @import("std");
const builtin = @import("builtin");
const c = @import("languages/c.zig");
const cpp = @import("languages/cpp.zig");
const go = @import("languages/go.zig");
const java = @import("languages/java.zig");
const javascript = @import("languages/javascript.zig");
const python = @import("languages/python.zig");
const rust = @import("languages/rust.zig");
const zigc = @import("languages/zig.zig");

pub fn handleBuild(file: []const u8, output_dir: ?[]const u8) !void {
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
    } else if (std.mem.endsWith(u8, file, ".js")) {
        try javascript.compileJavascript(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.compilePython(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".rs")) {
        try rust.compileRust(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.compileZig(file, output_dir);
    } else {
        std.debug.print("Unsupported file type: {s}\n", .{file});
        return;
    }
}

pub fn handleRun(file: []const u8, remaining_args: []const []const u8) !void {
    if (std.mem.endsWith(u8, file, ".class")) {
        try java.runJava(file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".js")) {
        try javascript.runJavascript(file);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.runPython(file);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.runZig(file);
    } else {
        std.debug.print("Unsupported file type for run command: {s}\n", .{file});
        return;
    }
}