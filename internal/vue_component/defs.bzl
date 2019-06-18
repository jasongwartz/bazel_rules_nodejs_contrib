#  Copyright 2018 Ecosia GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

def _vue_component(ctx):
    config = ctx.actions.declare_file("_%s.rollup.config.js" % ctx.label.name)
    filename = ctx.attr.out if ctx.attr.out else "%s.vue" % ctx.label.name
    build_js = ctx.actions.declare_file("%s.js" % filename)

    ctx.actions.expand_template(
        output = config,
        template = ctx.file._rollup_config_tmpl,
        substitutions = {
            "TMPL_src_name": ctx.file.src.path,
        },
    )

    args = ctx.actions.args()
    args.add_all(["--config", config.path])
    args.add_all(["--output.file", build_js.path])
    args.add_all(["--input", ctx.file.src.path])
    args.add("--silent")
    ctx.actions.run(
        executable = ctx.executable._rollup,
        inputs = [ctx.file.src, config],
        outputs = [build_js],
        arguments = [args],
    )

    return [
        DefaultInfo(files = depset([build_js])),
    ]

vue_component = rule(
    implementation = _vue_component,
    attrs = {
        "src": attr.label(
            doc = """Vue source files from the workspace.
            These can use ES2015 syntax and ES Modules (import/export)""",
            allow_single_file = [".vue"],
        ),
        "out": attr.string(
            default = "",
        ),
        "_rollup_config_tmpl": attr.label(
            default = Label("//internal/vue_component:rollup.config.js"),
            allow_single_file = True,
        ),
        "_rollup": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//internal/vue_component:rollup_vue"),
        ),
    },
)
