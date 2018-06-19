def _json_to_js(ctx):
    outputs = [ctx.actions.declare_file(src.path[:-4] + "js") for src in ctx.files.srcs]
    
    args = ctx.actions.args()
    args.add(["--out-dir", ctx.bin_dir.path])
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        executable = ctx.executable._json_to_js,
        inputs = ctx.files.srcs,
        outputs = outputs,
        arguments = [args],
    )

    return [
      DefaultInfo(files=depset(outputs)),
    ]

json_to_js = rule(
    implementation = _json_to_js,
    attrs = {
        "srcs": attr.label_list(
            doc = """JSON source files from the workspace.""",
            allow_files = [".json"]),
        "_json_to_js": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//tools/rules/json_to_js:json_to_js")),
    },
)
