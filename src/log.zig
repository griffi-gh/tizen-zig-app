const std = @import("std");
const meta = @import("meta.zig");
const c = @import("c.zig").c;

pub fn log(comptime level: std.log.Level, message: [:0]const u8) void {
    const levelDlog = switch (level) {
        .debug => c.DLOG_DEBUG,
        .info => c.DLOG_INFO,
        .warn => c.DLOG_WARN,
        .err => c.DLOG_ERROR,
    };

    _ = c.dlog_print(
        levelDlog,
        @ptrCast(meta.LOG_TAG),
        @ptrCast(message),
    );
}

pub fn logFmt(comptime level: std.log.Level, comptime fmt: []const u8, args: anytype) void {
    //TODO: remove hidden use of allocator here
    const alloc = std.heap.c_allocator;
    const message = std.fmt.allocPrintZ(alloc, fmt, args) catch return;
    defer alloc.free(message);
    log(level, message);
}

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime fmt: []const u8,
    args: anytype,
) void {
    const scopeName = @tagName(scope);
    logFmt(
        level,
        std.fmt.comptimePrint(
            "({s}) {s}",
            .{ scopeName, fmt },
        ),
        args,
    );
}

fn LogFn(comptime level: std.log.Level) type {
    return struct {
        fn logFn(message: [:0]const u8) void {
            log(level, message);
        }
        fn logFmtFn(comptime fmt: [:0]const u8, args: anytype) void {
            logFmt(level, fmt, args);
        }
    };
}

pub const debug = LogFn(.debug).logFn;
pub const info = LogFn(.info).logFn;
pub const warn = LogFn(.warn).logFn;
pub const err = LogFn(.err).logFn;

pub const debugFmt = LogFn(.debug).logFmtFn;
pub const infoFmt = LogFn(.info).logFmtFn;
pub const warnFmt = LogFn(.warn).logFmtFn;
pub const errFmt = LogFn(.err).logFmtFn;
