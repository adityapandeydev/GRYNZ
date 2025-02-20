const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileJavascript(file: []const u8, output_dir: ?[]const u8) !void {
    std.debug.print(
        \\Node doesn't create a binary, will use pkg instead.
        \\This will install Node_18 on your system.
        \\Are you sure? (y/n): 
        , .{});

    // Read user input
    var input: [2]u8 = undefined;
    _ = try std.io.getStdIn().read(input[0..1]);
    const choice = input[0];

    if (choice == 'y' or choice == 'Y') {
        const allocator = std.heap.page_allocator;
        var args = std.ArrayList([]const u8).init(allocator);
        defer args.deinit();

        try args.append("pkg");
        try args.append(file);

        // Extract the base name of the input file (without extension)
        const filename = std.fs.path.basename(file);
        const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
        const binary_name = filename[0..dot_index];

        // Set output path
        if (output_dir) |dir| {
            const output_path = try std.fs.path.join(allocator, &.{ dir, binary_name });
            try args.append("--output");
            try args.append(output_path);
            try args.append("--targets");
            try args.append("node18-win-x64");
        } else {
            try args.append("--output");
            try args.append(binary_name);
            try args.append("--targets");
            try args.append("node18-win-x64");
        }

        // Execute the pkg command
        try utils.executeCommand(allocator, args.items);
    } else {
        std.debug.print("Aborted.\n", .{});
    }
}

pub fn runJavascript(file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("node");
    try args.append(file);

    // Spawn the process
    try utils.executeCommand(allocator, args.items);
}