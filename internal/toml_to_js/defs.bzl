def _toml_to_js(ctx):
    outputs = [ctx.actions.declare_file(src.basename[:-4] + "js") for src in ctx.files.srcs]
    
    args = ctx.actions.args()
    args.add(["--out-dir", outputs[0].dirname])
    if ctx.attr.strict:
        args.add(["--strict"])
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        executable = ctx.executable._toml_to_js,
        inputs = ctx.files.srcs,
        outputs = outputs,
        arguments = [args],
    )

    return [
      DefaultInfo(files=depset(outputs)),
    ]

toml_to_js = rule(
    implementation = _toml_to_js,
    attrs = {
        "srcs": attr.label_list(
            doc = """TOML source files from the workspace.""",
            allow_files = [".toml"]),
        "strict": attr.bool(
            doc = """If strict is false it will parse not fully adhering the toml standard,
            e.g. ignoring comments but it is faster.""",
            default = True,
        ),
        "_toml_to_js": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//tools/rules/toml_to_js:toml_to_js")),
    },
)
