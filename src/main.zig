const std = @import("std");
const builtin = @import("builtin");

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

    // Check for --out flag
    if (args.len > 4 and std.mem.eql(u8, args[3], "--out")) {
        output_dir = args[4]; // Get output directory
    }

    if (std.mem.eql(u8, command, "build")) {
        if (!std.fs.path.isAbsolute(file)) {
            std.debug.print("Error: File {s} does not exist.\n", .{file});
            return;
        }
        try handleBuild(file, output_dir);
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
    }
}

fn handleBuild(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;

    // Extract filename without extension
    const filename_start = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename_start, '.') orelse filename_start.len;
    const ext = if (builtin.os.tag == .windows) ".exe" else ".out";
    const filename_no_ext = filename_start[0..dot_index];

    // Determine output file path
    var output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        output_path = try std.mem.concat(allocator, u8, &.{ dir, "/", filename_no_ext, ext });
    } else {
        output_path = try std.mem.concat(allocator, u8, &.{ filename_no_ext, ext });
    }

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    if (std.fs.cwd().access(file, .{})) |_| {
        if (std.mem.endsWith(u8, file, ".c")) {
            try args.appendSlice(&.{ "gcc", file, "-o", output_path });
        } else if (std.mem.endsWith(u8, file, ".cpp")) {
            try args.appendSlice(&.{ "g++", file, "-o", output_path });
        } else if (std.mem.endsWith(u8, file, ".rs")) {
            try args.appendSlice(&.{ "rustc", file, "-o", output_path });
        } else if (std.mem.endsWith(u8, file, ".go")) {
            try args.appendSlice(&.{ "go", "build", "-o", output_path, file });
        }
    } else |_| {
        std.debug.print("Error: File {s} does not exist.\n", .{file});
        return;
    }


    // Execute the compiler command
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = args.items,
        .cwd = null,
        .env_map = null,
    });

    // Print compiler output
    if (result.stdout.len > 0) {
        std.debug.print("Output:\n{s}\n", .{result.stdout});
    }
    if (result.stderr.len > 0) {
        std.debug.print("Errors:\n{s}\n", .{result.stderr});
    }

    std.debug.print("Compiled {s} → {s}\n", .{ file, output_path });
}