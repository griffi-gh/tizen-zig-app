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
    _ = tizen_data_path;

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
        "(unused) Tizen GCC toolchain version. Defaults to 9.2",
    ) orelse "9.2";
    _ = tizen_toolchain_version;

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
    // if (tizen_target == TizenTarget.device) {
    //     std.debug.print("{}", .{try b.sysroot});
    // }

    const target = b.resolveTargetQuery(.{
        .cpu_arch = switch (tizen_target) {
            .device => std.Target.Cpu.Arch.arm,
            .emulator => std.Target.Cpu.Arch.x86,
        },
        .os_tag = std.Target.Os.Tag.linux,
        .abi = std.Target.Abi.musleabi,
        // .abi = std.Target.Abi.gnueabi,
        // .glibc_version = std.SemanticVersion{
        //     // 2.24
        //     .major = 2,
        //     .minor = 24,
        //     .patch = 0,
        // },
    });

    // ---

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.pie = true; // Needs PIE for Tizen

    const includes = [_][]const u8{
        "usr/include",                                 "usr/include/libxml2",                      "usr/include/appcore-agent",
        "usr/include/appcore-watch",                   "usr/include/appfw",                        "usr/include/asp/",
        "usr/include/badge",                           "usr/include/base",                         "usr/include/cairo",
        "usr/include/calendar-service2",               "usr/include/chromium-ewk",                 "usr/include/ckm",
        "usr/include/component_based/base/api",        "usr/include/component_based/efl_base/api", "usr/include/contacts-svc",
        "usr/include/content",                         "usr/include/context-service",              "usr/include/context-service/wearable/",
        "usr/include/csr",                             "usr/include/dali",                         "usr/include/dali-toolkit",
        "usr/include/dbus-1.0",                        "usr/include/device",                       "usr/include/device-certificate-manager",
        "usr/include/dlog",                            "usr/include/ecore-1",                      "usr/include/ecore-buffer-1",
        "usr/include/ecore-con-1",                     "usr/include/ecore-evas-1",                 "usr/include/ecore-file-1",
        "usr/include/ecore-imf-1",                     "usr/include/ecore-imf-evas-1",             "usr/include/ecore-input-1",
        "usr/include/ecore-input-evas-1",              "usr/include/ecore-ipc-1",                  "usr/include/edje-1",
        "usr/include/eet-1",                           "usr/include/efl-1",                        "usr/include/efl-extension",
        "usr/include/efreet-1",                        "usr/include/eina-1",                       "usr/include/eina-1/eina",
        "usr/include/eio-1",                           "usr/include/elementary-1",                 "usr/include/embryo-1",
        "usr/include/emile-1",                         "usr/include/eo-1",                         "usr/include/eom",
        "usr/include/ethumb-1",                        "usr/include/ethumb-client-1",              "usr/include/evas-1",
        "usr/include/feedback",                        "usr/include/fontconfig",                   "usr/include/freetype2",
        "usr/include/gio-unix-2.0",                    "usr/include/glib-2.0",                     "usr/include/harfbuzz",
        "usr/include/iotcon",                          "usr/include/json-glib-1.0",                "usr/include/location",
        "usr/include/maps",                            "usr/include/media",                        "usr/include/media-content",
        "usr/include/messaging",                       "usr/include/metadata-editor",              "usr/include/minicontrol",
        "usr/include/minizip",                         "usr/include/network",                      "usr/include/nnstreamer",
        "usr/include/notification",                    "usr/include/notification-ex",              "usr/include/notification-ex/api",
        "usr/include/nsd/",                            "usr/include/phonenumber-utils",            "usr/include/privacy-privilege-manager/",
        "usr/include/rpc-port",                        "usr/include/SDL2",                         "usr/include/sensor",
        "usr/include/storage",                         "usr/include/system",                       "usr/include/tef",
        "usr/include/telephony",                       "usr/include/tzsh",                         "usr/include/ui",
        "usr/include/vulkan",                          "usr/include/watchface-common",             "usr/include/watchface-complication",
        "usr/include/watchface-complication-provider", "usr/include/widget_service",               "usr/include/widget_viewer_dali",
        "usr/include/widget_viewer_evas",              "usr/include/yaca",                         "usr/lib/dbus-1.0/include",
        "usr/lib/glib-2.0/include",
    };

    // Then in your build function:
    for (includes) |include| {
        exe.addSystemIncludePath(b.path(b.pathJoin(&.{ b.sysroot.?, include })));
    }

    const libs = [_][]const u8{
        "accounts-svc",                    "anl",                           "appcore-agent",
        "appcore-watch",                   "asp",                           "badge",
        "base-utils-i18n",                 "BrokenLocale",                  "bundle",
        "cairo",                           "calendar-service2",             "capi-appfw-alarm",
        "capi-appfw-app-common",           "capi-appfw-app-control",        "capi-appfw-app-control-uri",
        "capi-appfw-application",          "capi-appfw-app-manager",        "capi-appfw-component-manager",
        "capi-appfw-event",                "capi-appfw-job-scheduler",      "capi-appfw-package-manager",
        "capi-appfw-preference",           "capi-appfw-widget-application", "capi-base-common",
        "capi-content-media-content",      "capi-content-mime-type",        "capi-context-motion",
        "capi-context",                    "capi-location-manager",         "capi-maps-service",
        "capi-media-audio-io",             "capi-media-camera",             "capi-media-codec",
        "capi-media-controller",           "capi-mediademuxer",             "capi-media-image-util",
        "capi-media-metadata-editor",      "capi-media-metadata-extractor", "capi-mediamuxer",
        "capi-media-player",               "capi-media-radio",              "capi-media-recorder",
        "capi-media-sound-manager",        "capi-media-sound-pool",         "capi-media-streamer",
        "capi-media-streamrecorder",       "capi-media-thumbnail-util",     "capi-media-tone-player",
        "capi-media-tool",                 "capi-media-vision",             "capi-media-wav-player",
        "capi-messaging-email",            "capi-messaging-messages",       "capi-network-bluetooth",
        "capi-network-connection",         "capi-network-http",             "capi-network-inm",
        "capi-network-nfc",                "capi-network-smartcard",        "capi-network-softap",
        "capi-network-stc",                "capi-network-wifi-manager",     "capi-nnstreamer",
        "capi-privacy-privilege-manager",  "capi-system-battery-monitor",   "capi-system-device",
        "capi-system-info",                "capi-system-media-key",         "capi-system-runtime-info",
        "capi-system-sensor",              "capi-system-system-settings",   "capi-telephony",
        "capi-ui-autofill-common",         "capi-ui-autofill-manager",      "capi-ui-autofill-service",
        "capi-ui-autofill",                "capi-ui-efl-util",              "capi-ui-inputmethod-manager",
        "capi-ui-inputmethod",             "capi-ui-sticker-consumer",      "capi-ui-sticker-provider",
        "chromium-ewk",                    "cidn",                          "component-based-application",
        "component-based-core-base",       "contacts-service2",             "core-sync-client",
        "crypto",                          "crypt",                         "c",
        "csr-client",                      "curl",                          "dali-adaptor",
        "dali-core",                       "dali-toolkit",                  "data-control",
        "device-certificate-manager",      "dlog",                          "dl",
        "dpm",                             "ecore_buffer",                  "ecore_con",
        "ecore_evas",                      "ecore_file",                    "ecore_imf_evas",
        "ecore_imf",                       "ecore_input_evas",              "ecore_input",
        "ecore_ipc",                       "ecore",                         "edje",
        "eet",                             "efl-extension",                 "efreet_mime",
        "efreet",                          "efreet_trash",                  "eina",
        "eio",                             "elementary",                    "embryo",
        "eom",                             "eo",                            "ethumb_client",
        "ethumb",                          "evas",                          "exif",
        "feedback",                        "fido-client",                   "fontconfig",
        "freetype",                        "gio-2.0",                       "glib-2.0",
        "gmodule-2.0",                     "gobject-2.0",                   "gthread-2.0",
        "harfbuzz-icu",                    "harfbuzz",                      "icudata",
        "icui18n",                         "icuio",                         "icutest",
        "icutu",                           "icuuc",                         "iotcon",
        "json-glib-1.0",                   "key-manager-client",            "ma",
        "message-port",                    "minicontrol-provider",          "minicontrol-viewer",
        "minizip",                         "m",                             "notification-ex",
        "notification",                    "nsd-dns-sd",                    "nsd-ssdp",
        "nsl",                             "nss_compat",                    "nss_dns",
        "nss_files",                       "nss_hesiod",                    "nss_nisplus",
        "nss_nis",                         "oauth2",                        "oauth",
        "openal",                          "phonenumber-utils",             "privilege-info",
        "pthread",                         "push",                          "resolv",
        "rpc-port",                        "rt",                            "sqlite3",
        "ssl",                             "storage",                       "stt_engine",
        "stt",                             "tbm",                           "teec",
        "thread_db",                       "ttrace",                        "tts_engine",
        "tts",                             "tzsh_common",                   "tzsh_quickpanel",
        "tzsh_softkey",                    "util",                          "vc-elm",
        "vc_engine",                       "vc_manager",                    "vc",
        "watchface-complication-provider", "watchface-complication",        "widget_service",
        "widget_viewer_dali",              "widget_viewer_evas",            "xml2",
        "yaca",                            "z",
    };

    exe.addLibraryPath(b.path(b.pathJoin(&.{ b.sysroot.?, "/usr/lib" })));

    for (libs) |lib| {
        exe.linkSystemLibrary(lib);
        // exe.linkSystemLibrary2(lib, std.Build.Module.LinkSystemLibraryOptions{
        //     .needed = true,
        //     .weak = true,
        // });
    }

    b.installArtifact(exe);

    // build tpk step
    // const tpk_step = b.addStep("build tpk", "Build tpk file for Tizen");
    // tpk_step.dependOn(&run_exe.step);
}
