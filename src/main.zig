const std = @import("std");

const c = @cImport({
    @cInclude("app.h");
    @cInclude("Elementary.h");
    @cInclude("system_settings.h");
    @cInclude("efl_extension.h");
    @cInclude("dlog.h");
});

const PACKAGE: []const u8 = "org.example.basicui";

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    _ = c.elm_win_util_standard_add(@ptrCast(PACKAGE), @ptrCast(PACKAGE));
}
