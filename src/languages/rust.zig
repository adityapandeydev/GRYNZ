const std = @import("std");

pub fn compileRust(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("rustc");
    try args.append(file);
    try args.append("-o");

    // Construct output path
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    if (output_dir) |dir| {
        // Join directory with filename
        const output = try std.fs.path.join(allocator, &.{ dir, name });
        defer allocator.free(output);
        try args.append(output);

        var child = std.process.Child.init(args.items, allocator);
        try child.spawn();
        _ = try child.wait();
    } else {
        try args.append(name);

        var child = std.process.Child.init(args.items, allocator);
        try child.spawn();
        _ = try child.wait();
    }
}
