const std = @import("std");

pub fn compileZig(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("build-exe");
    try args.append(file);

    // Construct output path
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    if (output_dir) |dir| {
        // Join directory with filename
        const output = try std.fs.path.join(allocator, &.{ dir, name });
        defer allocator.free(output);

        // Add the -femit-bin flag with the output path
        const emit_arg = try std.fmt.allocPrint(allocator, "-femit-bin={s}", .{output});
        defer allocator.free(emit_arg);
        try args.append(emit_arg);
    } else {
        // Use the filename in the current directory
        const emit_arg = try std.fmt.allocPrint(allocator, "-femit-bin={s}", .{name});
        defer allocator.free(emit_arg);
        try args.append(emit_arg);
    }

    // Spawn the process
    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}

pub fn runZig(file: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("zig");
    try args.append("run");
    try args.append(file);

    var child = std.process.Child.init(args.items, allocator);
    try child.spawn();
    _ = try child.wait();
}