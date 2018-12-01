def _test_sources_aspect_impl(target, ctx):
    result = depset()

    if hasattr(ctx.rule.attr, "tags") and "NODE_MODULE_MARKER" in ctx.rule.attr.tags:
        return struct(node_test_sources=result)

    if hasattr(ctx.rule.attr, "deps"):
        for dep in ctx.rule.attr.deps:
            if hasattr(dep, "node_test_sources"):
                result = depset(transitive=[result, dep.node_test_sources])
    elif hasattr(target, "files"):
        result = depset([f for f in target.files.to_list() if f.path.endswith(".test.js")],
                        transitive=[result])

    return struct(node_test_sources=result)


test_sources_aspect = aspect(
    _test_sources_aspect_impl,
    attr_aspects=["deps"],
)
