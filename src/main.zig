const std = @import("std");
// const _ = @import("./x86_rt.zig");

const builtin = @import("builtin");

// HACK
fn zig_probe_stack() callconv(.Naked) void {
    @setRuntimeSafety(false);
    asm volatile (
        \\        push   %%ecx
        \\        mov    %%eax, %%ecx
        \\        cmp    $0x1000,%%ecx
        \\        jb     2f
        \\ 1:
        \\        sub    $0x1000,%%esp
        \\        orl    $0,8(%%esp)
        \\        sub    $0x1000,%%ecx
        \\        cmp    $0x1000,%%ecx
        \\        ja     1b
        \\ 2:
        \\        sub    %%ecx, %%esp
        \\        orl    $0,8(%%esp)
        \\        add    %%eax,%%esp
        \\        pop    %%ecx
        \\        ret
    );
    unreachable;
}
comptime {
    if ((builtin.cpu.arch == .x86) or (builtin.cpu.arch == .x86_64)) {
        @export(zig_probe_stack, .{ .name = "__zig_probe_stack", .linkage = .weak });
    }
}

const c = @cImport({
    @cDefine("__GLIBC_USE(FEATURE)", "(FEATURE)");
    @cInclude("app.h");
    @cInclude("Elementary.h");
    @cInclude("system_settings.h");
    @cInclude("efl_extension.h");
    @cInclude("dlog.h");
});

const PACKAGE: []const u8 = "org.example.basicui";

fn win_delete_request_cb(_: ?*anyopaque, _: ?*c.struct__Eo_Opaque, _: ?*anyopaque) callconv(.C) void {
    c.ui_app_exit();
}

fn win_back_cb(_: ?*anyopaque, _: ?*c.struct__Eo_Opaque, _: ?*anyopaque) callconv(.C) void {
    // appdata_s *ad = data;
    // /* Let window go to hide state. */
    // elm_win_lower(window);
    c.ui_app_exit();
}

fn base_ui() void {
    const window = c.elm_win_util_standard_add(@ptrCast(PACKAGE), @ptrCast(PACKAGE));
    c.elm_win_autodel_set(window, c.EINA_TRUE);

    if (c.elm_win_wm_rotation_supported_get(window) == c.EINA_TRUE) {
        const rots = [_]c_int{ 0, 90, 180, 270 };
        c.elm_win_wm_rotation_available_rotations_set(window, &rots[0], rots.len);
    }

    c.evas_object_smart_callback_add(window, "delete,request", win_delete_request_cb, c.NULL);
    c.eext_object_event_callback_add(window, c.EEXT_CALLBACK_BACK, win_back_cb, c.NULL);

    // Create and initialize elm_conformant.
    // elm_conformant is mandatory for base gui to have proper size
    // when indicator or virtual keypad is visible.
    const conform = c.elm_conformant_add(window);
    c.elm_win_indicator_mode_set(window, c.ELM_WIN_INDICATOR_SHOW);
    c.elm_win_indicator_opacity_set(window, c.ELM_WIN_INDICATOR_OPAQUE);
    c.evas_object_size_hint_weight_set(conform, c.EVAS_HINT_EXPAND, c.EVAS_HINT_EXPAND);
    c.elm_win_resize_object_add(window, conform);
    c.evas_object_show(conform);

    const label = c.elm_label_add(conform);
    const text: [*c]const u8 = "<align=center>Hello Tizen</align>";
    c.elm_object_part_text_set(label, null, text);
    c.evas_object_size_hint_weight_set(label, c.EVAS_HINT_EXPAND, c.EVAS_HINT_EXPAND);
    c.elm_object_part_content_set(conform, null, label);

    // Show window after base gui is set up
    c.evas_object_show(window);
}

fn app_create_cb(_: ?*anyopaque) callconv(.C) bool {
    base_ui();
    return true;
}

fn app_main() !c_int {
    var allocator = std.heap.page_allocator;

    var argv = std.ArrayList([*:0]const u8).init(allocator);
    defer argv.deinit();
    var process_args = std.process.args();
    while (process_args.next()) |arg| {
        const c_arg = try allocator.dupeZ(u8, arg); // Convert to null-terminated C string
        try argv.append(c_arg);
    }

    var event_callback = c.ui_app_lifecycle_callback_s{
        .create = app_create_cb,
    };
    const ret = c.ui_app_main(
        @intCast(argv.items.len),
        @ptrCast(argv.items.ptr),
        @ptrCast(&event_callback),
        null,
    );

    return ret;
}

export fn main() void {
    const ret = app_main() catch |err| {
        // c.dlog_print(c.DLOG_ERROR, @ptrCast(c.LOG_TAG), "Error caught: %s\n", err);
        std.debug.print("Error caught: {}\n", .{err});
        std.process.exit(1);
    };
    if (ret != c.APP_ERROR_NONE) {
        _ = c.dlog_print(c.DLOG_ERROR, @ptrCast(c.LOG_TAG), "app_main() is failed. err = %d", ret);
        std.process.exit(@intCast(ret));
    }
}
