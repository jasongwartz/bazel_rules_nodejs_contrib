
def _collect_sources(ctx):
  es5_sources = depset(ctx.files.srcs)
  transitive_es5_sources = depset()
  transitive_es6_sources = depset()
  for dep in ctx.attr.deps:
    if hasattr(dep, "typescript"):
        transitive_es5_sources = depset(transitive = [
            transitive_es5_sources,
            dep.typescript.transitive_es5_sources,
        ])
        transitive_es6_sources = depset(transitive = [
            transitive_es6_sources,
            dep.typescript.transitive_es6_sources,
        ])

  return struct(
    es5_sources = es5_sources,
    transitive_es5_sources = depset(transitive = [transitive_es5_sources, es5_sources]),
    es6_sources = es5_sources,
    transitive_es6_sources = depset(transitive = [transitive_es6_sources, es5_sources])
  )

def _js_library(ctx):
    js = _collect_sources(ctx)

    # Note: This struct is for compatibility with bazelbuild/rules_nodejs. Right now they do not
    # provide a stable API / generic Providers. It is planned for the 1.0 release.
    return struct(
        typescript = struct(
            es6_sources = js.es6_sources,
            transitive_es6_sources = js.transitive_es6_sources,
            es5_sources = js.es5_sources,
            transitive_es5_sources = js.transitive_es5_sources,
        ),
        legacy_info = struct(
            files = js.es5_sources,
            tags = ctx.attr.tags,
            module_name =  ctx.attr.module_name,
        ),
        providers = [
            DefaultInfo(files = js.es5_sources),
        ],
    )

js_library = rule(
    implementation = _js_library,
    attrs = {
        "srcs": attr.label_list(allow_files = [".js", ".mjs", ".jsx", ".vue"]),
        "deps": attr.label_list(allow_files = True),
        "module_name": attr.string(),
        "module_root": attr.string(),
    },
)