const std = @import("std");
const builtin = @import("builtin");

pub fn compileRust(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("rustc");
    try args.append(file);
    try args.append("-o");

    // Extract filename without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    // Ensure a correct output path
    var final_output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        final_output_path = try std.fs.path.join(allocator, &.{ dir, name });
    } else {
        final_output_path = name;
    }

    // Ensure `.exe` extension on Windows
    const ext = if (builtin.os.tag == .windows) ".exe" else "";
    const final_output = try std.mem.concat(allocator, u8, &.{ final_output_path, ext });
    try args.append(final_output);

    // Spawn the process
    var child = std.process.Child.init(args.items, allocator);
    child.stderr_behavior = .Inherit; // Show errors directly in the console
    try child.spawn();
    _ = try child.wait();

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(final_output);
}
