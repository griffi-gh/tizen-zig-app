pub const c = @cImport({
    @cDefine("__GLIBC_USE(FEATURE)", "(FEATURE)");
    @cInclude("app.h");
    @cInclude("Elementary.h");
    @cInclude("system_settings.h");
    @cInclude("efl_extension.h");
    @cInclude("dlog.h");
});
