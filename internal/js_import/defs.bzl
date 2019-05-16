def _js_import(ctx):
    sources = depset(ctx.files.srcs)
    # Note: This struct is for compatibility with bazelbuild/rules_nodejs. Right now they do not
    # provide a stable API / generic Providers. It is planned for the 1.0 release.
    return struct(
        typescript = struct(
            es6_sources = sources,
            transitive_es6_sources = sources,
            es5_sources = sources,
            transitive_es5_sources = sources,
        ),
        legacy_info = struct(
            files = sources,
            tags = ctx.attr.tags,
        ),
        providers = [
            DefaultInfo(files = sources),
        ],
    )

js_import = rule(
    implementation = _js_import,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)