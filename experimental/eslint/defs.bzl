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

# TODO(Markus): Allow for full customization, including with custom plugins etc.
# Extract inline bash content out into a template file
# Also right now we use the $BUILD_WORKSPACE_DIRECTORY to modify the files outsied the sandbox
# directly, investigate the possibility of symlinking required files into the sandbox.
# Also when modified_files_only is set to true, it currently filters to .js and .vue files
# hardcoded. Further it implicitely requires git, sed and grep. See if this can be improved.
# Add bazel_skylib to Workspace.

def _array_literal(iterable):
  return "(" + " ".join([str(i) for i in iterable]) + ")"

def _eslint_impl(ctx):
    args = ["-c", ctx.file.config.path, "--ext .js,.vue"]
    args.extend(["--ignore-path", "\"$BUILD_WORKSPACE_DIRECTORY/.gitignore\""])
    if ctx.attr.modified_files_only:
        args.extend(["$modified_files"])
    else:
        args.extend(["\"$BUILD_WORKSPACE_DIRECTORY/%s\"" % path for path in ctx.attr.paths])
    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    ctx.actions.write(
        output = out_file,
        content = """#!/usr/bin/env bash
set -euo pipefail

if [ "%s" = True ] ; then
    modified_files=$(cd $BUILD_WORKSPACE_DIRECTORY && echo $(git diff HEAD^ --diff-filter=d --name-only | grep -E '\.js$|\.vue$'))
    modified_files=$(echo "$modified_files" | sed "s~[^ ]* *~$BUILD_WORKSPACE_DIRECTORY/&~g")
fi

ESLINT_SHORT_PATH=%s
ARGS=%s
if [ $# -ne 0 ]; then
  ARGS+=("$@")
fi
eslint_short_path=$(readlink "$ESLINT_SHORT_PATH")

# Set env variables node_launcher expects to be set from bazel
export RUNFILES_DIR=$(pwd)/..
export RUNFILES=$(pwd)/..
export RUNFILES_MANIFEST_ONLY=1
export RUNFILES_MANIFEST_FILE=$(pwd)/../MANIFEST

"$eslint_short_path" "${ARGS[@]}"
""" % (ctx.attr.modified_files_only, shell.quote(ctx.executable._eslint.short_path), _array_literal(args)),
        is_executable = True,
    )

    transitive_depsets = []
    default_runfiles = ctx.attr._eslint[DefaultInfo].default_runfiles
    if default_runfiles != None:
        transitive_depsets.append(default_runfiles.files)

    runfiles = ctx.runfiles(
      files = ctx.files._eslint + ctx.files.data + ctx.files._bash + [ctx.file.config],
      transitive_files = depset([], transitive = transitive_depsets),
    )
    return [DefaultInfo(
        files = depset([out_file]),
        runfiles = runfiles,
        executable = out_file,
    )]


eslint = rule(
    implementation = _eslint_impl,
    attrs = {
        "paths": attr.string_list(
            doc = """Directories to lint. Will be ignored if modified_files_only is set.""",
            default = ["."],
        ),
        "modified_files_only": attr.bool(
            doc = """Will automatically lint all files changed since the latest commit. Will ignore paths.""",
            default = False,
        ),
        "config": attr.label(
            doc = """Eslint config""",
            default = Label("//experimental/eslint:.eslintrc.js"),
            allow_single_file = [".js"],
        ),
        "data": attr.label_list(
            doc = "Further dpendencies",
            allow_files = True,
        ),
        "_eslint": attr.label(
            executable = True,
            cfg = "target",
            default = Label("//experimental/eslint:eslint")
        ),
        "_bash": attr.label(
            cfg = "target",
            allow_files = True,
            default = Label("@bazel_tools//tools/bash/runfiles"),
        )
    },
    executable = True,
)
