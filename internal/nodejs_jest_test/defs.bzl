load("@ecosia_bazel_rules_nodejs_contrib//internal/nodejs_jest_test:test_sources_aspect.bzl",
     "test_sources_aspect")
load("@build_bazel_rules_nodejs//internal/common:module_mappings.bzl", "module_mappings_runtime_aspect")
load("@build_bazel_rules_nodejs//internal/common:sources_aspect.bzl", "sources_aspect")
load("@build_bazel_rules_nodejs//internal/common:expand_into_runfiles.bzl", "expand_location_into_runfiles")
load("@build_bazel_rules_nodejs//internal/common:node_module_info.bzl", "NodeModuleInfo", "collect_node_modules_aspect")
load("@ecosia_bazel_rules_nodejs_contrib//internal/nodejs_jest_test:node.bzl", "nodejs_binary_impl", "short_path_to_manifest_path",
     "NODEJS_EXECUTABLE_OUTPUTS", "NODEJS_EXECUTABLE_ATTRS")


def _node_jest_test_impl(ctx):
    test_sources = ctx.files.srcs
    ctx.actions.expand_template(
        template=ctx.file._jest_template,
        output=ctx.outputs.jest,
        substitutions={
            "TEMPLATED_env": "\"" + ctx.attr.env + "\"",
            # "TEMPLATED_ci": "true" if get_ci(ctx) else "false",
            "TEMPLATED_ci": "false",
            "TEMPLATED_filePaths": "[" + ",\n  ".join(
                ["\"" + f.short_path + "\"" for f in test_sources]) + "]",
            "TEMPLATED_update": "true" if ctx.attr.update_snapshots else "false",
        },
    )

    return nodejs_binary_impl(
        ctx,
        entry_point=short_path_to_manifest_path(
            ctx, ctx.outputs.jest.short_path),
        files=[ctx.outputs.jest] + test_sources,
    )


node_jest_test = rule(
    _node_jest_test_impl,
    attrs=dict(NODEJS_EXECUTABLE_ATTRS, **{
        "entry_point": attr.string(
            mandatory=False,
        ),
        "srcs": attr.label_list(
            doc = """Test source files""",
            allow_files=True,
        ),
        "data": attr.label_list(
            allow_files=True,
            aspects=[sources_aspect, module_mappings_runtime_aspect, collect_node_modules_aspect]), # test_sources_aspect
        "env": attr.string(
            default="jsdom",
            values=["node", "jsdom"]
        ),
        "update_snapshots": attr.bool(
            default=False,
        ),
        "_jest_template": attr.label(
            default=Label(
                "@ecosia_bazel_rules_nodejs_contrib//internal/nodejs_jest_test:jest-runner.js"),
            allow_files=True,
            single_file=True),
    }),
    test=True,
    executable = True,
    outputs=dict(NODEJS_EXECUTABLE_OUTPUTS, **{
        "jest": "%{name}_jest.js",
    }),
)

node_jest = rule(
    _node_jest_test_impl,
    attrs=dict(NODEJS_EXECUTABLE_ATTRS, **{
        "entry_point": attr.string(
            mandatory=False,
        ),
        "srcs": attr.label_list(
            doc = """Test source files""",
            allow_files=True,
        ),
        "data": attr.label_list(
            allow_files=True,
            aspects=[sources_aspect, module_mappings_runtime_aspect, collect_node_modules_aspect]), # test_sources_aspect
        "env": attr.string(
            default="jsdom",
            values=["node", "jsdom"]
        ),
        "update_snapshots": attr.bool(
            default=False,
        ),
        "_jest_template": attr.label(
            default=Label(
                "@ecosia_bazel_rules_nodejs_contrib//internal/nodejs_jest_test:jest-runner.js"),
            allow_files=True,
            single_file=True),
    }),
    executable = True,
    outputs=dict(NODEJS_EXECUTABLE_OUTPUTS, **{
        "jest": "%{name}_jest.js",
    }),
)


def _node_jest_test_macro_base(name, srcs, data=[], args=[], visibility=None, tags=[], **kwargs):
    node_jest_test(
        name=name,
        srcs=srcs,
        data=data + ["@bazel_tools//tools/bash/runfiles",],
                    #  "@npm//jest",
                    #  "@npm//jest-cli",
                    #  "@npm//fs-extra"],
        # testonly=1,
        tags=tags,
        # visibility=["//visibility:private"],
        visibility=visibility,
        args=args,
        **kwargs
    )

    node_jest(
        name=name + ".binary",
        srcs=srcs,
        data=data + ["@bazel_tools//tools/bash/runfiles",],
                    #  "@npm//jest",
                    #  "@npm//jest-cli",
                    #  "@npm//fs-extra"],
        # testonly=1,
        tags=tags,
        # visibility=["//visibility:private"],
        visibility=visibility,
        args=args,
        **kwargs
    )

    # native.sh_binary(
    #     name = "%s_bin_bin" % name,
    #     srcs=["//internal/nodejs_jest_test:runner.sh"],
    #     data = [
    #         ":%s_bin.sh" % name,
    #         ":%s_bin" % name,
    #     ],
    #     tags=tags,
    #     visibility=visibility,
    #     testonly=1,
    # )

    # native.sh_binary(
    #     name=name,
    #     args=args,
    #     tags=tags,
    #     visibility=visibility,
    #     # srcs = ["//internal/nodejs_jest_test:runner.sh"],
    #     # srcs = [":%s_bin_bin" % name],
    #     srcs=[":%s_bin.sh" % name],
    #     data=[":%s_bin.sh" % name, ":%s_bin" % name],
    #     testonly = 1,
    # )

# Note: The deps attribute is just to have api compatibility with test rules from other languages
def node_jest_test_macro(name, srcs, deps=[], tags=[], data=[], **kwargs):
    _node_jest_test_macro_base(
        name=name,
        srcs=srcs,
        tags=tags,
        data=data + deps,
        **kwargs
    )

    _node_jest_test_macro_base(
        name="%s_update" % name,
        srcs=srcs,
        update_snapshots=True,
        data=data + deps,
        tags=tags + ["manual", "update-jest-snapshot"],
        **kwargs
    )
