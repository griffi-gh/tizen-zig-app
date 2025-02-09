const std = @import("std");
const builtin = @import("builtin");
const meta = @import("./meta.zig");
const log = @import("./log.zig");
const c = @import("./c.zig").c;

pub const std_options = .{
    .logFn = log.logFn,
};

const app_state = struct {
    window: ?*c.Evas_Object,
    conform: ?*c.Evas_Object,
    label: ?*c.Evas_Object,
};

fn win_delete_request_cb(_: ?*anyopaque, _: ?*c.struct__Eo_Opaque, _: ?*anyopaque) callconv(.C) void {
    c.ui_app_exit();
}

fn win_back_cb(user_data: ?*anyopaque, _: ?*c.struct__Eo_Opaque, _: ?*anyopaque) callconv(.C) void {
    const app: *app_state = @ptrCast(@alignCast(user_data));
    c.elm_win_lower(app.window);
    // c.ui_app_exit();
}

fn base_ui(app: *app_state) void {
    app.window = c.elm_win_util_standard_add(
        @ptrCast(meta.PACKAGE),
        @ptrCast(meta.PACKAGE),
    );
    c.elm_win_autodel_set(app.window, c.EINA_TRUE);
    c.elm_win_indicator_mode_set(app.window, c.ELM_WIN_INDICATOR_SHOW);
    c.elm_win_indicator_opacity_set(app.window, c.ELM_WIN_INDICATOR_OPAQUE);
    if (c.elm_win_wm_rotation_supported_get(app.window) == c.EINA_TRUE) {
        const rots = [_]c_int{ 0, 90, 180, 270 };
        c.elm_win_wm_rotation_available_rotations_set(app.window, &rots[0], rots.len);
    }
    c.evas_object_smart_callback_add(app.window, "delete,request", win_delete_request_cb, c.NULL);
    c.eext_object_event_callback_add(app.window, c.EEXT_CALLBACK_BACK, win_back_cb, c.NULL);

    // Create and initialize elm_conformant.
    // elm_conformant is mandatory for base gui to have proper size
    // when indicator or virtual keypad is visible.
    app.conform = c.elm_conformant_add(app.window);
    c.evas_object_size_hint_weight_set(app.conform, c.EVAS_HINT_EXPAND, c.EVAS_HINT_EXPAND);
    c.elm_win_resize_object_add(app.window, app.conform);
    c.evas_object_show(app.conform);

    app.label = c.elm_label_add(app.conform);
    c.elm_object_part_text_set(app.label, null, "<align=center>Hello from Zig</align>");
    c.evas_object_size_hint_weight_set(app.label, c.EVAS_HINT_EXPAND, c.EVAS_HINT_EXPAND);
    c.elm_object_part_content_set(app.conform, null, app.label);

    // Show window after base gui is set up
    c.evas_object_show(app.window);
}

fn app_create_cb(ad: ?*anyopaque) callconv(.C) bool {
    base_ui(@ptrCast(@alignCast(ad)));
    return true;
}
fn app_resume_cb(_: ?*anyopaque) callconv(.C) void {}
fn app_app_contorl_cb(_: ?*c.struct_app_control_s, _: ?*anyopaque) callconv(.C) void {}
fn app_pause_cb(_: ?*anyopaque) callconv(.C) void {}
fn app_terminate_cb(_: ?*anyopaque) callconv(.C) void {}

fn app_main(c_argc: c_int, c_argv: [*c][*c]u8) !c_int {
    var event_callback = c.ui_app_lifecycle_callback_s{
        .@"resume" = app_resume_cb,
        .app_control = app_app_contorl_cb,
        .create = app_create_cb,
        .pause = app_pause_cb,
        .terminate = app_terminate_cb,
    };
    var user_data = app_state{
        .window = null,
        .conform = null,
        .label = null,
    };

    const ret = c.ui_app_main(
        c_argc,
        c_argv,
        &event_callback,
        &user_data,
    );

    return ret;
}

fn _main(c_argc: c_int, c_argv: [*c][*c]u8) callconv(.C) c_int {
    std.log.info("init main", .{});
    const ret = app_main(c_argc, c_argv) catch |err| {
        std.log.err("Error caught: {}\n", .{err});
        return 1;
    };
    if (ret != c.APP_ERROR_NONE) {
        std.log.err("app_main() is failed. err = {}", .{ret});
    }
    return ret;
}

comptime {
    @export(_main, .{ .name = "main", .linkage = .strong });
}

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
    if (builtin.cpu.arch == .x86) {
        @export(zig_probe_stack, .{ .name = "__zig_probe_stack", .linkage = .weak });
    }
}
