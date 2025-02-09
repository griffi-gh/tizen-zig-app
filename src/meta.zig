const std = @import("std");

pub const PACKAGE: []const u8 = "org.example.zig-app";
pub const LOG_TAG: []const u8 = std.fmt.comptimePrint("APP_{s}", .{PACKAGE});
