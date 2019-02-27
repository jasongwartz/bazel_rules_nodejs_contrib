load("@build_bazel_rules_nodejs//:defs.bzl", _nodejs_test = "nodejs_test")

def _jest_node_test_impl(ctx):
    test_sources = ctx.files.srcs

    ctx.actions.write(
        output = ctx.outputs.jest_runner,
        content = """
        #!/usr/bin/env bash

        set -euo pipefail

        {env}

        ARGS="{config_args} --runTestsByPath "

        if [ $# -ne 0 ]; then
            ARGS+="$@"
        else
            ARGS+="{run_tests_args}"
        fi

        exec {jest} $ARGS
        """.format(
            env = "\n".join(["export %s=%s" % (key, ctx.attr.env[key]) for key in ctx.attr.env]) if ctx.attr.env else "",
            jest = ctx.files.jest[0].short_path,
            config_args = "-c " + ctx.file.config.short_path,
            run_tests_args = " ".join([f.short_path for f in test_sources]),
        ),
        is_executable = True,
    )

    transitive_depsets = ctx.attr.jest[DefaultInfo].default_runfiles.files

    return [DefaultInfo(
        runfiles = ctx.runfiles(
            transitive_files = depset([], transitive = [transitive_depsets]),
        ),
        executable = ctx.outputs.jest_runner,
      )]


_jest_node_test = rule(
    _jest_node_test_impl,
    attrs={
        "srcs": attr.label_list(
            doc = """Test source files""",
            allow_files=True,
        ),
        "jest_env": attr.string(
            default="jsdom",
            values=["node", "jsdom"]
        ),
        "env": attr.string_dict(
            default={},
        ),
        "update_snapshots": attr.bool(
            default=False,
        ),
        "config": attr.label(
            doc = """jest config file""",
            allow_single_file = True,
            mandatory = False,
        ),
        "jest": attr.label(
            mandatory=True,
            allow_files=True,
        ),
    },
    test=True,
    executable = True,
    outputs={
        "jest_runner": "%{name}.sh",
    },
)

def jest_node_test(name, srcs, config, jest, **kwargs):
    data = kwargs.pop("data", []) + srcs + [config]
    env = kwargs.pop("env", {})
    tags = kwargs.pop("tags", [])
    visibility = kwargs.pop("visibility", [])

    _nodejs_test(
        name = "%s_test" % name,
        data = data,
        # Note: We do not want to run this target automatically as it will fail
        # tags = tags + ["manual"],
        visibility = ["//visibility:private"],
        **kwargs
    )

    _jest_node_test(
        name = name,
        srcs = srcs,
        config = config,
        jest = "%s_test" % name,
        env = env,
        tags = tags,
        visibility = visibility,
    )
