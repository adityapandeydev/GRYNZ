const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "grynz",
        .root_source_file = b.path("src/main.zig"),
        .target = target,  // REQUIRED for Zig 0.13.0
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    b.step("run", "Run Grynz").dependOn(&run_cmd.step);
}

// zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl
// zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows-msvc
// zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos --prefix .\zig-out\bin\macos 