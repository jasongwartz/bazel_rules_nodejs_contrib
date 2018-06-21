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
    ctx.actions.expand_template(
        output = config,
        template =  ctx.file._rollup_config_tmpl,
        substitutions = {
            "TMPL_src_name": ctx.file.src.path,
        }
    )
    
    args = ctx.actions.args()
    args.add(["--config", config.path])
    args.add(["--output.file", ctx.outputs.build_js.path])
    args.add(["--input", ctx.file.src.path])
    ctx.actions.run(
        executable = ctx.executable._rollup,
        inputs = [ctx.file.src, config],
        outputs = [ctx.outputs.build_js],
        arguments = [args],
    )

vue_component = rule(
    implementation = _vue_component,
    attrs = {
        "src": attr.label(
            doc = """Vue source files from the workspace.
            These can use ES2015 syntax and ES Modules (import/export)""",
            single_file = True,
            allow_files = [".vue"]),
        "_rollup_config_tmpl": attr.label(
            default = Label("//internal/vue_component:rollup.config.js"),
            allow_files = True,
            single_file = True),
        "_rollup": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//internal/vue_component:rollup_vue")),
    },
    outputs = {
        "build_js": "%{name}.js",
        # "build_css": "%{name}.css",
    },
)
