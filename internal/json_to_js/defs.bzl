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

def _json_to_js(ctx):
    outputs = [ctx.actions.declare_file(src.basename[:-4] + "js") for src in ctx.files.srcs]
    
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
            default = Label("//internal/json_to_js:json_to_js")),
    },
)
