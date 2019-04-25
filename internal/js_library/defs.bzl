def _js_library(ctx):
    return [
        DefaultInfo(files = depset(ctx.files.srcs)),
    ]

js_library = rule(
    implementation = _js_library,
    attrs = {
        "srcs": attr.label_list(allow_files = [".js"]),
        "deps": attr.label_list(allow_files = True)
        "module_name": attr.string(),
        "module_root": attr.string(),
    },
)