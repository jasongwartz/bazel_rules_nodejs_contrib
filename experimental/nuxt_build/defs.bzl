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

load("@bazel_skylib//:lib.bzl", "paths")

def _nuxt_build(ctx):
    output_dir = ctx.actions.declare_directory(".nuxt")
    bin_dir_config = ctx.actions.declare_file(ctx.label.name + ctx.file.nuxt_config.basename)

    path_package_to_root = ""

    if ctx.label.package:
      for i in range(ctx.label.package.count("/") + 1):
        path_package_to_root += "../"


    ctx.actions.expand_template(
      template = ctx.file.nuxt_config,
      output = bin_dir_config,
      substitutions = {
        "<bazel-bin>": path_package_to_root + ctx.bin_dir.path,
      }
    )
    
    args = ctx.actions.args()
    args.add("build")
    args.add("-c")
    args.add(path_package_to_root + bin_dir_config.path)
    if ctx.label.package:
      args.add(ctx.label.package)
    
    ctx.actions.run(
        executable = ctx.executable._nuxt,
        inputs = ctx.files.srcs + ctx.files.node_modules + [bin_dir_config],
        outputs = [output_dir],
        arguments = [args],
        mnemonic = "NuxtBuild",
        progress_message = "Creating nuxt production assets for %s" % ctx.label.name
    )

    return [
        DefaultInfo(
            files=depset(direct=[output_dir]),
        ),
    ]

nuxt_build = rule(
    implementation = _nuxt_build,
    attrs = {
        "srcs": attr.label_list(
            doc = """Vue and js source files from the workspace.""",
            allow_files = [".vue", ".js"]
        ),
        "nuxt_config": attr.label(
            doc = """Nuxt config file""",
            allow_single_file = True,
            mandatory = True,
        ),
        "node_modules": attr.label(
            doc = """Dependencies from npm that provide some modules that must be resolved by babel.""",
        ),
        "_nuxt": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//experimental/nuxt_build:nuxt")
        ),
    },
)
