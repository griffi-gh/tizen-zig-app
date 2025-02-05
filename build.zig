const std = @import("std");

const TizenArch = enum {
    arm,
    x86,
};

const TizenPlatform = enum {
    mobile,
    wearable,
    tv,
};

pub fn build(b: *std.Build) void {
    const tizen_studio_path = b.option(
        []const u8,
        "tizen-studio-path",
        "Path to Tizen Studio installation directory (default is ~/tizen-studio)",
    ) orelse "~/tizen-studio";
    _ = tizen_studio_path;

    const tizen_data_path = b.option(
        []const u8,
        "tizen-data-path",
        "Path to Tizen Studio data directory (default is ~/tizen-studio-data)",
    ) orelse "~/tizen-studio-data";
    _ = tizen_data_path;

    const tizen_target = b.option(
        TizenArch,
        "tizen-target",
        "Tizen target architecture; arm (default) for devices and x86 for emulator",
    ) orelse TizenArch.arm;
    _ = tizen_target;

    const tizen_platform = b.option(
        TizenPlatform,
        "tizen-platform",
        "Tizen platform (defaults to wearable)",
    ) orelse TizenPlatform.wearable;
    _ = tizen_platform;

    const tizen_toolchain_version = b.option(
        []const u8,
        "tizen-toolchain-version",
        "Tizen GCC toolchain version. Defaults to 9.2",
    ) orelse "9.2";
    _ = tizen_toolchain_version;

    //TODO create target from tizen_target instead
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // build tpk step
    // const tpk_step = b.addStep("build tpk", "Build tpk file for Tizen");
    // tpk_step.dependOn(&run_exe.step);
}
