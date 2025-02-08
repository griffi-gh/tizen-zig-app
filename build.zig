const std = @import("std");

const TizenTarget = enum {
    device,
    emulator,
};

const TizenPlatform = enum {
    mobile,
    wearable,
    tv,
};

pub fn build(b: *std.Build) !void {
    const tizen_path = b.option(
        []const u8,
        "tizen-path",
        "Path to Tizen Studio installation directory (default is ~/tizen-studio)",
    ) orelse "./sdk/tizen-studio";

    const tizen_data_path = b.option(
        []const u8,
        "tizen-data-path",
        "Path to Tizen Studio data directory (default is ~/tizen-studio-data)",
    ) orelse "./sdk/tizen-studio-data";

    const tizen_target = b.option(
        TizenTarget,
        "tizen-target",
        "Tizen target architecture; device is default",
    ) orelse TizenTarget.device;

    const tizen_platform = b.option(
        TizenPlatform,
        "tizen-platform",
        "Tizen platform (defaults to wearable)",
    ) orelse TizenPlatform.wearable;

    const tizen_api_version = b.option(
        []const u8,
        "tizen-api-version",
        "Tizen API version (default is 5.5)",
    ) orelse "5.5";

    const tizen_toolchain_version = b.option(
        []const u8,
        "tizen-toolchain-version",
        "Tizen GCC toolchain version. Defaults to 6.2 (for Tizen 5.5)",
    ) orelse "6.2";
    // _ = tizen_toolchain_version;

    const tizen_platform_name = switch (tizen_platform) {
        TizenPlatform.mobile => "mobile",
        TizenPlatform.wearable => "wearable",
        TizenPlatform.tv => "tv",
    };

    const tizen_target_name = switch (tizen_target) {
        TizenTarget.device => "device",
        TizenTarget.emulator => "emulator",
    };

    const tizen_sysroot = try std.fmt.allocPrint(
        b.allocator,
        "{s}/platforms/tizen-{s}/{s}/rootstraps/{s}-{s}-{s}.core/",
        .{
            tizen_path,
            tizen_api_version,
            tizen_platform_name,
            tizen_platform_name,
            tizen_api_version,
            tizen_target_name,
        },
    );
    b.sysroot = tizen_sysroot;

    const target = b.resolveTargetQuery(.{
        .cpu_arch = switch (tizen_target) {
            .device => std.Target.Cpu.Arch.arm,
            .emulator => std.Target.Cpu.Arch.x86,
        },
        .os_tag = std.Target.Os.Tag.linux,
        .abi = switch (tizen_target) {
            .device => std.Target.Abi.musleabi,
            .emulator => std.Target.Abi.musl,
        },
        .ofmt = .elf,
        // .abi = std.Target.Abi.gnueabi,
    });

    // ---

    const optimize = b.standardOptimizeOption(.{});

    // const exe = b.addExecutable(.{
    //     .name = "zig-test",
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe.pie = true; // Needs PIE for Tizen
    // exe.link_gc_sections = false;

    const obj = b.addObject(.{
        .name = "app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const includes = [_][]const u8{
        "usr/include",
        "usr/include/libxml2",
        "usr/include/appcore-agent",
        "usr/include/appcore-watch",
        "usr/include/appfw",
        "usr/include/asp/",
        "usr/include/badge",
        "usr/include/base",
        "usr/include/cairo",
        "usr/include/calendar-service2",
        "usr/include/chromium-ewk",
        "usr/include/ckm",
        "usr/include/component_based/base/api",
        "usr/include/component_based/efl_base/api",
        "usr/include/contacts-svc",
        "usr/include/content",
        "usr/include/context-service",
        "usr/include/context-service/wearable/",
        "usr/include/csr",
        "usr/include/dali",
        "usr/include/dali-toolkit",
        "usr/include/dbus-1.0",
        "usr/include/device",
        "usr/include/device-certificate-manager",
        "usr/include/dlog",
        "usr/include/ecore-1",
        "usr/include/ecore-buffer-1",
        "usr/include/ecore-con-1",
        "usr/include/ecore-evas-1",
        "usr/include/ecore-file-1",
        "usr/include/ecore-imf-1",
        "usr/include/ecore-imf-evas-1",
        "usr/include/ecore-input-1",
        "usr/include/ecore-input-evas-1",
        "usr/include/ecore-ipc-1",
        "usr/include/edje-1",
        "usr/include/eet-1",
        "usr/include/efl-1",
        "usr/include/efl-extension",
        "usr/include/efreet-1",
        "usr/include/eina-1",
        "usr/include/eina-1/eina",
        "usr/include/eio-1",
        "usr/include/elementary-1",
        "usr/include/embryo-1",
        "usr/include/emile-1",
        "usr/include/eo-1",
        "usr/include/eom",
        "usr/include/ethumb-1",
        "usr/include/ethumb-client-1",
        "usr/include/evas-1",
        "usr/include/feedback",
        "usr/include/fontconfig",
        "usr/include/freetype2",
        "usr/include/gio-unix-2.0",
        "usr/include/glib-2.0",
        "usr/include/harfbuzz",
        "usr/include/iotcon",
        "usr/include/json-glib-1.0",
        "usr/include/location",
        "usr/include/maps",
        "usr/include/media",
        "usr/include/media-content",
        "usr/include/messaging",
        "usr/include/metadata-editor",
        "usr/include/minicontrol",
        "usr/include/minizip",
        "usr/include/network",
        "usr/include/nnstreamer",
        "usr/include/notification",
        "usr/include/notification-ex",
        "usr/include/notification-ex/api",
        "usr/include/nsd/",
        "usr/include/phonenumber-utils",
        "usr/include/privacy-privilege-manager/",
        "usr/include/rpc-port",
        "usr/include/SDL2",
        "usr/include/sensor",
        "usr/include/storage",
        "usr/include/system",
        "usr/include/tef",
        "usr/include/telephony",
        "usr/include/tzsh",
        "usr/include/ui",
        "usr/include/vulkan",
        "usr/include/watchface-common",
        "usr/include/watchface-complication",
        "usr/include/watchface-complication-provider",
        "usr/include/widget_service",
        "usr/include/widget_viewer_dali",
        "usr/include/widget_viewer_evas",
        "usr/include/yaca",
        "usr/lib/dbus-1.0/include",
        "usr/lib/glib-2.0/include",
    };
    for (includes) |include| {
        obj.addSystemIncludePath(b.path(b.pathJoin(&.{ b.sysroot.?, include })));
    }

    const obj_install = b.addInstallFile(obj.getEmittedBin(), "app.o");
    obj_install.step.dependOn(&obj.step);

    const libs = [_][]const u8{
        "-laccounts-svc",
        "-lanl",
        "-lappcore-agent",
        "-lappcore-watch",
        "-lasp",
        "-lbadge",
        "-lbase-utils-i18n",
        "-lBrokenLocale",
        "-lbundle",
        "-lcairo",
        "-lcalendar-service2",
        "-lcapi-appfw-alarm",
        "-lcapi-appfw-app-common",
        "-lcapi-appfw-app-control",
        "-lcapi-appfw-app-control-uri",
        "-lcapi-appfw-application",
        "-lcapi-appfw-app-manager",
        "-lcapi-appfw-component-manager",
        "-lcapi-appfw-event",
        "-lcapi-appfw-job-scheduler",
        "-lcapi-appfw-package-manager",
        "-lcapi-appfw-preference",
        "-lcapi-appfw-widget-application",
        "-lcapi-base-common",
        "-lcapi-content-media-content",
        "-lcapi-content-mime-type",
        "-lcapi-context-motion",
        "-lcapi-context",
        "-lcapi-location-manager",
        "-lcapi-maps-service",
        "-lcapi-media-audio-io",
        "-lcapi-media-camera",
        "-lcapi-media-codec",
        "-lcapi-media-controller",
        "-lcapi-mediademuxer",
        "-lcapi-media-image-util",
        "-lcapi-media-metadata-editor",
        "-lcapi-media-metadata-extractor",
        "-lcapi-mediamuxer",
        "-lcapi-media-player",
        "-lcapi-media-radio",
        "-lcapi-media-recorder",
        "-lcapi-media-sound-manager",
        "-lcapi-media-sound-pool",
        "-lcapi-media-streamer",
        "-lcapi-media-streamrecorder",
        "-lcapi-media-thumbnail-util",
        "-lcapi-media-tone-player",
        "-lcapi-media-tool",
        "-lcapi-media-vision",
        "-lcapi-media-wav-player",
        "-lcapi-messaging-email",
        "-lcapi-messaging-messages",
        "-lcapi-network-bluetooth",
        "-lcapi-network-connection",
        "-lcapi-network-http",
        "-lcapi-network-inm",
        "-lcapi-network-nfc",
        "-lcapi-network-smartcard",
        "-lcapi-network-softap",
        "-lcapi-network-stc",
        "-lcapi-network-wifi-manager",
        "-lcapi-nnstreamer",
        "-lcapi-privacy-privilege-manager",
        "-lcapi-system-battery-monitor",
        "-lcapi-system-device",
        "-lcapi-system-info",
        "-lcapi-system-media-key",
        "-lcapi-system-runtime-info",
        "-lcapi-system-sensor",
        "-lcapi-system-system-settings",
        "-lcapi-telephony",
        "-lcapi-ui-autofill-common",
        "-lcapi-ui-autofill-manager",
        "-lcapi-ui-autofill-service",
        "-lcapi-ui-autofill",
        "-lcapi-ui-efl-util",
        "-lcapi-ui-inputmethod-manager",
        "-lcapi-ui-inputmethod",
        "-lcapi-ui-sticker-consumer",
        "-lcapi-ui-sticker-provider",
        "-lchromium-ewk",
        "-lcidn",
        "-lcomponent-based-application",
        "-lcomponent-based-core-base",
        "-lcontacts-service2",
        "-lcore-sync-client",
        "-lcrypto",
        "-lcrypt",
        "-lc",
        "-lcsr-client",
        "-lcurl",
        // "-ldali-adaptor",
        // "-ldali-core",
        // "-ldali-toolkit",
        "-ldata-control",
        // "-ldevice-certificate-manager",
        "-ldlog",
        "-ldl",
        // "-ldpm",
        "-lecore_buffer",
        "-lecore_con",
        "-lecore_evas",
        "-lecore_file",
        "-lecore_imf_evas",
        "-lecore_imf",
        "-lecore_input_evas",
        "-lecore_input",
        "-lecore_ipc",
        "-lecore",
        "-ledje",
        "-leet",
        "-lefl-extension",
        "-lefreet_mime",
        "-lefreet",
        "-lefreet_trash",
        "-leina",
        "-leio",
        "-lelementary",
        "-lembryo",
        "-leom",
        "-leo",
        "-lethumb_client",
        "-lethumb",
        "-levas",
        "-lexif",
        "-lfeedback",
        "-lfido-client",
        "-lfontconfig",
        "-lfreetype",
        "-lgio-2.0",
        "-lglib-2.0",
        "-lgmodule-2.0",
        "-lgobject-2.0",
        "-lgthread-2.0",
        "-lharfbuzz-icu",
        "-lharfbuzz",
        "-licudata",
        "-licui18n",
        "-licuio",
        "-licutest",
        "-licutu",
        "-licuuc",
        "-liotcon",
        "-ljson-glib-1.0",
        "-lkey-manager-client",
        "-lma",
        "-lmessage-port",
        "-lminicontrol-provider",
        "-lminicontrol-viewer",
        "-lminizip",
        "-lm",
        "-lnotification-ex",
        "-lnotification",
        "-lnsd-dns-sd",
        "-lnsd-ssdp",
        "-lnsl",
        "-lnss_compat",
        "-lnss_dns",
        "-lnss_files",
        "-lnss_hesiod",
        "-lnss_nisplus",
        "-lnss_nis",
        "-loauth2",
        "-loauth",
        "-lopenal",
        "-lphonenumber-utils",
        "-lprivilege-info",
        "-lpthread",
        "-lpush",
        "-lresolv",
        "-lrpc-port",
        "-lrt",
        "-lsqlite3",
        "-lssl",
        "-lstorage",
        "-lstt_engine",
        "-lstt",
        "-ltbm",
        "-lteec",
        "-lthread_db",
        "-lttrace",
        "-ltts_engine",
        "-ltts",
        "-ltzsh_common",
        "-ltzsh_quickpanel",
        "-ltzsh_softkey",
        "-lutil",
        "-lvc-elm",
        "-lvc_engine",
        "-lvc_manager",
        "-lvc",
        "-lwatchface-complication-provider",
        "-lwatchface-complication",
        "-lwidget_service",
        "-lwidget_viewer_dali",
        "-lwidget_viewer_evas",
        "-lxml2",
        "-lyaca",
        "-lz",

        // GCC
        // "-lc",
        // "-lm",
        // "-lstdc++",
    };

    const exe_path = b.pathJoin(&.{ b.install_path, "app" });
    const tizen_arch_name_gcc = switch (tizen_target) {
        TizenTarget.device => "arm",
        TizenTarget.emulator => "i586",
    };
    const linker_path = try std.fmt.allocPrint(
        b.allocator,
        "{s}/tools/{s}-linux-gnueabi-gcc-{s}/bin/{s}-linux-gnueabi-gcc",
        .{
            tizen_path,
            tizen_arch_name_gcc,
            tizen_toolchain_version,
            tizen_arch_name_gcc,
        },
    );
    const link_exe = b.addSystemCommand(&[_][]const u8{
        linker_path,
        "-o",
        exe_path,
        b.pathJoin(&.{ b.install_path, obj_install.dest_rel_path }),
        "-fmessage-length=0",
    });
    if (obj.pie orelse false) {
        link_exe.addArg("-fPIE");
    }
    if (b.sysroot) |sysroot| {
        link_exe.addArg(try std.fmt.allocPrint(
            b.allocator,
            "--sysroot={s}",
            .{sysroot},
        ));
    }
    link_exe.addArgs(&libs);
    link_exe.step.dependOn(&obj_install.step);

    b.getInstallStep().dependOn(&link_exe.step);

    // ---
    const built_tpk = b.addSystemCommand(&[_][]const u8{
        "/usr/bin/env",
        try std.fmt.allocPrint(
            b.allocator,
            "TIZEN={s}",
            .{tizen_path},
        ),
        try std.fmt.allocPrint(
            b.allocator,
            "TIZEN_DATA={s}",
            .{tizen_data_path},
        ),
        "./scripts/build-pkg.sh",
    });
    built_tpk.step.dependOn(&link_exe.step);

    const build_tpk_step = b.step("tpk", "Build, package and sign a Tizen package (requires TIZEN_SIGNING_PROFILE and TIZEN_SIGNING_PASSWORD to be set)");
    build_tpk_step.dependOn(&built_tpk.step);

    // -- install

    // use sdb to install the file
    const install_tpk = b.addSystemCommand(&[_][]const u8{
        try std.fmt.allocPrint(
            b.allocator,
            "{s}/tools/sdb",
            .{tizen_path},
        ),
        "install",
        "./zig-out/app.tpk",
    });
    install_tpk.step.dependOn(&built_tpk.step);

    const install_tpk_step = b.step("sideload", "Install the Tizen package on the connected device");
    install_tpk_step.dependOn(&install_tpk.step);
}
