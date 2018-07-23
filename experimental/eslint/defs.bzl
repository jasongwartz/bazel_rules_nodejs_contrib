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
load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")

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

echo "Running: eslint ${ARGS[@]}"

"$eslint_short_path" "${ARGS[@]}"
""" % (ctx.attr.modified_files_only, shell.quote(ctx.executable.eslint.short_path), _array_literal(args)),
        is_executable = True,
    )

    transitive_depsets = []
    default_runfiles = ctx.attr.eslint[DefaultInfo].default_runfiles
    if default_runfiles != None:
        transitive_depsets.append(default_runfiles.files)

    runfiles = ctx.runfiles(
      files = ctx.files.eslint + ctx.files.data + ctx.files._bash + [ctx.file.config],
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
        "eslint": attr.label(
            executable = True,
            cfg = "target",
        ),
        "_bash": attr.label(
            cfg = "target",
            allow_files = True,
            default = Label("@bazel_tools//tools/bash/runfiles"),
        )
    },
    executable = True,
)

def eslint_macro(**kwargs):
    """eslint binary wrapper for `eslint`

    Args:
        **kwargs: node_modules and eslint_binary_name is passed to the binary, everything else is
        passed through to `eslint`
    """
    node_modules = kwargs.pop('node_modules', "@eslint_deps//:node_modules")
    # Allow a custom binary name to keep reusing the same binary on mutltiple rule instantiations
    eslint_binary_name = kwargs.pop('eslint_binary_name', "%s_eslint" % kwargs['name'])

    if eslint_binary_name not in native.existing_rules():
        nodejs_binary(
            name = eslint_binary_name,
            entry_point = "eslint/bin/eslint.js",
            node_modules = node_modules,
            visibility = ["//visibility:public"],
        )

    # get the absolute label for the above binary
    r = native.existing_rule(eslint_binary_name)

    if r['generator_location'].startswith("/"):
        eslint_bin = native.repository_name() + "//:" + r['name']
    else:
        eslint_bin = native.repository_name() + "//" + r['generator_location'].rsplit("/", maxsplit=1)[0] + ":" + r['name']

    kwargs["eslint"] = eslint_bin
    eslint(**kwargs)
