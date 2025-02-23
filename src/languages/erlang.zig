const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileErlang(file: []const u8, output_dir: ?[]const u8) !void {
    const allocator = std.heap.page_allocator;
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("erlc");

    if (output_dir) |dir| {
        try args.append("-o");
        try args.append(dir);
    }

    try args.append(file);

    try utils.executeCommand(allocator, args.items);
}

pub fn runErlang(file: []const u8, remaining_args: []const []const u8) !void {
    const allocator = std.heap.page_allocator;
    var entry_function: ?[]const u8 = null;

    // Parse remaining arguments for --entry
    var i: usize = 0;
    while (i < remaining_args.len) {
        if (std.mem.eql(u8, remaining_args[i], "--entry")) {
            if (i + 1 < remaining_args.len) {
                entry_function = remaining_args[i + 1];
                i += 2;
            } else {
                std.debug.print("Error: --entry requires an entry function\n", .{});
                return error.MissingEntryFunction;
            }
        } else {
            std.debug.print("Unknown argument: {s}\n", .{remaining_args[i]});
            return error.UnknownArgument;
        }
    }

    if (entry_function == null) {
        std.debug.print("Error: --entry flag is required for running Erlang files\n", .{});
        return error.MissingEntryFunction;
    }

    // Extract module name without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const module_name = filename[0..dot_index];

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("erl");

    // Use the directory of the file as the classpath
    const file_dir = std.fs.path.dirname(file) orelse ".";
    try args.append("-pa");
    try args.append(file_dir);

    try args.append("-noshell");
    try args.append("-s");
    try args.append(module_name);
    try args.append(entry_function.?);
    try args.append("-s");
    try args.append("init");
    try args.append("stop");

    try utils.executeCommand(allocator, args.items);
}