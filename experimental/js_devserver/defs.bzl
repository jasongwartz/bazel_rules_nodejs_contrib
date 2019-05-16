def _js_devserver(ctx):
    files = depset()
    for d in ctx.attr.deps:
        if hasattr(d, "node_sources"):
            files = depset(transitive=[d.node_sources, files])
        elif hasattr(d, "files"):
            files = depset(transitive=[d.files, files])

    if ctx.label.workspace_root:
        # We need the workspace_name for the target being visited.
        # Skylark doesn't have this - instead they have a workspace_root
        # which looks like "external/repo_name" - so grab the second path segment.
        # TODO(alexeagle): investigate a better way to get the workspace name
        workspace_name = ctx.label.workspace_root.split("/")[1]
    else:
        workspace_name = ctx.workspace_name

    devserver_runfiles = [
        ctx.executable._devserver,
    ]
    devserver_runfiles += ctx.files.static_files
    devserver_runfiles += ctx.files.scripts

    serving_arg = ""
    if ctx.attr.serving_path:
        serving_arg = "-serving_path=%s" % ctx.attr.serving_path

    packages = depset(["/".join([workspace_name, ctx.label.package])] + ctx.attr.additional_root_paths)

    # FIXME: more bash dependencies makes Windows support harder
    ctx.actions.write(
        output = ctx.outputs.executable,
        is_executable = True,
        content = """#!/bin/sh
RUNFILES="$PWD/.."
{main} {serving_arg} \
  -base="$RUNFILES" \
  -packages={packages} \
  -entry_point={entry_point} \
  -port={port} \
  "$@"
""".format(
            main = ctx.executable._devserver.short_path,
            serving_arg = serving_arg,
            packages = ",".join(packages.to_list()),
            entry_point = ctx.attr.entry_point,
            port = str(ctx.attr.port),
        ),
    )
    return [DefaultInfo(
        runfiles = ctx.runfiles(
            files = devserver_runfiles,
            # We don't expect executable targets to depend on the devserver, but if they do,
            # they can see the JavaScript code.
            transitive_files = depset(ctx.files.data, transitive=[files]),
            collect_data = True,
            collect_default = True,
        ),
    )]


js_devserver = rule(
    implementation = _js_devserver,
    attrs = {
        "deps": attr.label_list(
            doc = "Targets that produce JavaScript, such as `ts_library`",
            allow_files = True,
            # aspects = [sources_aspect],
        ),
        "serving_path": attr.string(
            doc = """The path you can request from the client HTML which serves the JavaScript bundle.
            If you don't specify one, the JavaScript can be loaded at /_/ts_scripts.js""",
        ),
        "data": attr.label_list(
            doc = "Dependencies that can be require'd while the server is running",
            allow_files = True,
        ),
        "static_files": attr.label_list(
            doc = """Arbitrary files which to be served, such as index.html.
            They are served relative to the package where this rule is declared.""",
            allow_files = True,
        ),
        "scripts": attr.label_list(
            doc = "User scripts to include in the JS bundle before the application sources",
            allow_files = [".js"],
        ),
        "entry_point": attr.string(
            doc = """The starting point of the application.
            This should be a path relative to the workspace root.
            """,
        ),
        # "bootstrap": attr.label_list(
        #     doc = "Scripts to include in the JS bundle before the module loader (require.js)",
        #     allow_files = [".js"],
        # ),
        "additional_root_paths": attr.string_list(
            doc = """Additional root paths to serve static_files from.
            Paths should include the workspace name such as [\"__main__/resources\"]
            """,
        ),
        "port": attr.int(
            doc = """The port that the devserver will listen on.""",
            default = 8080,
        ),
        "_devserver": attr.label(
            default = Label("//experimental/devserver"),
            executable = True,
            cfg = "host",
        ),
    },
    executable = True,
)

"""js_devserver is a simple development server intended for a quick "getting started" experience.
"""

def js_devserver_macro(tags = [], **kwargs):
    """ibazel wrapper for `js_devserver`
    This macro re-exposes the `js_devserver` rule with some extra tags so that
    it behaves correctly under ibazel.
    This is re-exported in `//:defs.bzl` as `js_devserver` so if you load the rule
    from there, you actually get this macro.
    Args:
      tags: standard Bazel tags, this macro adds a couple for ibazel
      **kwargs: passed through to `js_devserver`
    """
    js_devserver(
        # Users don't need to know that these tags are required to run under ibazel
        tags = tags + [
            # Tell ibazel not to restart the devserver when its deps change.
            "ibazel_notify_changes",
            # Tell ibazel to serve the live reload script, since we expect a browser will connect to
            # this program.
            "ibazel_live_reload",
        ],
        **kwargs
    )
