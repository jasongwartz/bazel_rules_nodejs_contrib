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

def collect_es6_sources(ctx):
  non_rerooted_files = [d for d in ctx.files.deps if d.is_source]
  if hasattr(ctx.attr, "srcs"):
    non_rerooted_files += ctx.files.srcs
  for dep in ctx.attr.deps: 
    if hasattr(dep, "typescript"):
      non_rerooted_files += dep.typescript.transitive_es6_sources.to_list()


  rerooted_files = []
  for file in non_rerooted_files:
    if file.is_source:
      path = file.short_path
      if (path.startswith("../")):
          path = "external/" + path[3:]

      # rerooted_file = ctx.actions.declare_file(
      # "%s.es6/%s" % (
      #     ctx.label.name,
      #     # the .closure.js filename is an artifact of the rules_typescript layout
      #     # TODO(mrmeku): pin to end of string, eg. don't match foo.closure.jso.js
      #     path.replace(".js", ".js")))

      rerooted_file = ctx.actions.declare_file(
      "%s" % (
          # the .closure.js filename is an artifact of the rules_typescript layout
          # TODO(mrmeku): pin to end of string, eg. don't match foo.closure.jso.js
          path.replace(".js", ".js")))
      # Cheap way to create an action that copies a file
      # TODO(alexeagle): discuss with Bazel team how we can do something like
      # runfiles to create a re-rooted tree. This has performance implications.
      ctx.actions.expand_template(
          output = rerooted_file,
          template = file,
          substitutions = {}
      )
    else:
      rerooted_file = file

    rerooted_files += [rerooted_file]

  #TODO(mrmeku): we should include the files and closure_js_library contents too
  return depset(direct = rerooted_files)

def _dev_bundle(ctx):
    args = ctx.actions.args()
    args.add(["-E", "--map-inline"])
    # args.add([ctx.attr.entry_point])
    # args.add(["%s/%s.es6/%s" % (ctx.bin_dir.path, ctx.label.name, ctx.attr.entry_point)])
    args.add(["%s/%s" % (ctx.bin_dir.path, ctx.attr.entry_point)])
    args.add([ctx.outputs.build.path])

    sources = collect_es6_sources(ctx)
    inputs = sources + ctx.files.node_modules
    outputs = [ctx.outputs.build]

    # print(ctx.bin_dir.path)

    # ctx.actions.run_shell(
    #     command = "ls -lah %s/weather_widget_dev_bundle.es6/assets/scripts" % ctx.bin_dir.path,
    #     inputs = inputs,
    #     outputs = [ctx.outputs.build_test],
    #     arguments = [args],
    # )

    ctx.actions.run(
        executable = ctx.executable._pax,
        inputs = inputs,
        outputs = outputs,
        arguments = [args],
    )

    return [
      DefaultInfo(
        # files=depset(outputs + [ctx.outputs.build_test])
        files=depset(outputs)
      ),
    ]

dev_bundle = rule(
    implementation = _dev_bundle,
    attrs = {
        "entry_point": attr.string(
          doc = """The starting point of the application, passed as the `--input` flag to pax.
          This should be a path relative to the workspace root.
          """,
          mandatory = True),
        "srcs": attr.label_list(
          doc = """JavaScript source files from the workspace.
          These can use ES2015 syntax and ES Modules (import/export)""",
          allow_files = [".js"]),
        "deps": attr.label_list(
            doc = """Other rules that produce JavaScript outputs, such as `ts_library`.""",
            ),
        "node_modules": attr.label(
            doc = """Dependencies from npm that provide some modules that must be resolved by babel.""",
            default = Label("@//:node_modules")),
        "_pax": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "host",
            default = Label("@pax//linux-x86_64:pax")),
    },
    outputs = {
      "build": "%{name}.js",
      # "build_test": "%{name}.test.js",
    }
)
