const std = @import("std");
const utils = @import("../utils.zig");

pub fn compilePython(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;

    // Warning to the user
    std.debug.print(
        \\ Python does not natively compile to binaries.
        \\ You can use the `run` command instead:
        \\ Example: grynz run {s}
        \\ 
        \\ Press 'R' to run the script now.
        \\ Press 'Y' to continue compilation.
        \\ Press 'N' to exit.
        \\ > 
    , .{file});

    // Read user input
    var input: [2]u8 = undefined;
    _ = try std.io.getStdIn().read(input[0..1]);
    const choice = input[0];

    if (choice == 'R' or choice == 'r') {
        try runPython(file);
        return;
    } else if (choice == 'N' or choice == 'n') {
        std.debug.print("\nExiting. Use `grynz run {s}` to execute the script.\n", .{file});
        return;
    }

    // Proceed with compilation
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("python");
    try args.append("-m");
    try args.append("nuitka");
    try args.append("--standalone");
    try args.append("--onefile");
    try args.append(file);

    if (output_dir) |dir| {
        const out_flag = try std.mem.concat(allocator, u8, &.{"--output-dir=", dir});
        try args.append(out_flag);
    }

    // Spawn the process
    try utils.executeCommand(allocator, args.items);
}


pub fn runPython(file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("python");
    try args.append(file);

    // Spawn the process
    try utils.executeCommand(allocator, args.items);
}