const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dtw_module = b.addModule("dtw", .{
        .root_source_file = b.path("src/dtw.zig"),
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{
        .name = "dtw",
        .root_module = dtw_module,
    });

    unit_tests.root_module.addImport("dtw", dtw_module);
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Example
    const example_module = b.addModule("example", .{
        .root_source_file = b.path("example/example.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = example_module,
    });

    exe.root_module.addImport("dtw", dtw_module);

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const step_name = "run";
    const run_step = b.step(step_name, "Run the example");
    run_step.dependOn(&run_cmd.step);

    // generate docs
    const linkage = b.option(std.builtin.LinkMode, "dtw", "dtw linkage") orelse .static;
    const lib = b.addLibrary(.{
        .linkage = linkage,
        .name = "dtw",
        .root_module = dtw_module,
    });

    const docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    b.getInstallStep().dependOn(&docs.step);
}
