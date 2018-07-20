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
load("@bazel_skylib//:lib.bzl", "shell")

# TODO(Markus): Allow for full customization, including with plugins etc to load
# and see if we can make this a non-test rule

def _array_literal(iterable):
  return "(" + " ".join([str(i) for i in iterable]) + ")"

def _eslint_impl(ctx):
    args = ["-c", ctx.file.eslint_config.path, "--ext .js,.vue"]
    args.extend(["--ignore-path", "\"$BUILD_WORKSPACE_DIRECTORY/.gitignore\""])
    args.extend(["\"$BUILD_WORKSPACE_DIRECTORY/%s\"" % path for path in ctx.attr.paths])
    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    ctx.actions.write(
        output = out_file,
        content = """#!/usr/bin/env bash
set -euo pipefail

ESLINT_SHORT_PATH=%s
ARGS=%s
if [ $# -ne 0 ]; then
  ARGS+=("$@")
fi
eslint_short_path=$(readlink "$ESLINT_SHORT_PATH")
"$eslint_short_path" "${ARGS[@]}"
""" % (shell.quote(ctx.executable._eslint.short_path), _array_literal(args)),
        is_executable = True,
    )

    transitive_depsets = []
    default_runfiles = ctx.attr._eslint[DefaultInfo].default_runfiles
    if default_runfiles != None:
        transitive_depsets.append(default_runfiles.files)
        # transitive_depsets.append(ctx.attr._eslint[DefaultInfo].data_runfiles.files)

    runfiles = ctx.runfiles(
      files = ctx.files._eslint + [ctx.file.eslint_config],
      transitive_files = depset([], transitive = transitive_depsets),
    )
    return [DefaultInfo(
        files = depset([out_file]),
        runfiles = runfiles,
        executable = out_file,
    )]


eslint_test = rule(
    implementation = _eslint_impl,
    attrs = {
        "paths": attr.string_list(
            doc = """Directories to lint. <path>/... will recurse""",
            default = ["./**"],
        ),
        "eslint_config": attr.label(
            doc = """Eslint config""",
            default = Label("//experimental/eslint:.eslintrc.js"),
            allow_single_file = [".js"],
        ),
        "_eslint": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//experimental/eslint:eslint")),
    },
    test = True,
)
