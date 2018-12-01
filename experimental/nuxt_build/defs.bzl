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

load("@bazel_skylib//lib:paths.bzl", "paths")

def _make_resolve(ctx, val):
    if val[0:2] == "$(" and val[-1] == ")":
        if val[2:-1] not in ctx.var:
            fail("""%(val)s not found in configuration variables. Maybe you forgot to set --define
                 %(val)s=<value>?""" % {val: val[2:-1]})
        else:
            return ctx.var[val[2:-1]]
    else:
        return val

def _nuxt_build(ctx):
    output_dir = ctx.actions.declare_directory(".nuxt")
    
    args = ctx.actions.args()
    args.add("build")
    args.add("-c")
    args.add(ctx.file.nuxt_config.short_path)

    build_env = {
        "NUXT_BUILD_DIR_PREFIX": ctx.bin_dir.path + "/",
    }

    if ctx.attr.deps:
        sample_dep =str(ctx.attr.deps[0].label)
        if sample_dep.startswith("@"):
            external_workspace_name = sample_dep[1:sample_dep.index("//")]
            # This is currently necessary to get the nuxt 2.x esm stuff to work
            build_env['NODE_PATH'] = "external/{}/node_modules".format(external_workspace_name)
        else:
            fail("Deps needs to reference fine-grained node module dependencies from an external workspace.")

    if ctx.attr.node_env:
        build_env['NODE_ENV'] = _make_resolve(ctx, ctx.attr.node_env)
    
    ctx.actions.run(
        executable = ctx.executable.nuxt,
        inputs = ctx.files.srcs + ctx.files.deps + ctx.files.data + [ctx.file.nuxt_config],
        outputs = [output_dir],
        arguments = [args],
        mnemonic = "NuxtBuild",
        progress_message = "Creating nuxt production assets for %s" % ctx.label.name,
        env = build_env,
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
        "data": attr.label_list(
            doc = """Additional files, like package.json etc.""",
            allow_files =True,
        ),
        "deps": attr.label_list(
            doc = """Node module dependencies.""",
            allow_files =True,
        ),
        "node_env": attr.string(
            doc = """If set passes in the node env variable with the given value. Supports make
            variable substituon.""",
            default = "",
        ),
        "nuxt": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//experimental/nuxt_build:nuxt")
        ),
    },
)
