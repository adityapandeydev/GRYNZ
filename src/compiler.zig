const std = @import("std");
const builtin = @import("builtin");
const c = @import("languages/c.zig");
const cpp = @import("languages/cpp.zig");
const go = @import("languages/go.zig");
const java = @import("languages/java.zig");
const javascript = @import("languages/javascript.zig");
const kotlin = @import("languages/kotlin.zig");
const python = @import("languages/python.zig");
const rust = @import("languages/rust.zig");
const typescript = @import("languages/typescript.zig");
const zigc = @import("languages/zig.zig");

pub fn handleBuild(file: []const u8, remaining_args: []const []const u8) !void {
    var output_dir: ?[]const u8 = null;
    var include_runtime = false;

    // Parse remaining arguments
    var i: usize = 0;
    while (i < remaining_args.len) {
        if (std.mem.eql(u8, remaining_args[i], "--out")) {
            if (i + 1 < remaining_args.len) {
                output_dir = remaining_args[i + 1];
                i += 2;
            } else {
                std.debug.print("Error: --out requires an output directory\n", .{});
                return;
            }
        } else if (std.mem.eql(u8, remaining_args[i], "-include-runtime")) {
            include_runtime = true;
            i += 1;
        } else {
            std.debug.print("Unknown argument: {s}\n", .{remaining_args[i]});
            return;
        }
    }

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
    } else if (std.mem.endsWith(u8, file, ".kt")) {
        try kotlin.compileKotlin(file, output_dir, include_runtime);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.compilePython(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".rs")) {
        try rust.compileRust(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".ts")) {
        try typescript.compileTypescript(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.compileZig(file, output_dir);
    } else {
        std.debug.print("Unsupported file type: {s}\n", .{file});
        return;
    }
}

pub fn handleRun(file: []const u8, remaining_args: []const []const u8) !void {
    var output_dir: ?[]const u8 = null;

    if (remaining_args.len > 1 and std.mem.eql(u8, remaining_args[0], "--out")) {
        output_dir = remaining_args[1];
    }

    if (std.mem.endsWith(u8, file, ".class")) {
        try java.runJava(file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".js")) {
        try javascript.runJavascript(file);
    } else if (std.mem.endsWith(u8, file, ".jar")) {
        try kotlin.runKotlin(file);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.runPython(file);
    } else if (std.mem.endsWith(u8, file, ".ts")) {
        try typescript.runTypescript(file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.runZig(file);
    } else {
        std.debug.print("Unsupported file type for run command: {s}\n", .{file});
        return;
    }
}