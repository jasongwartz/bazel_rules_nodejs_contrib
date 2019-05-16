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

workspace(name = "ecosia_bazel_rules_nodejs_contrib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz"],
    strip_prefix = "bazel-skylib-0.8.0",
    sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
)

http_archive(
    name = "build_bazel_rules_nodejs",
    urls = ["https://github.com/bazelbuild/rules_nodejs/archive/0.27.12.tar.gz"],
    strip_prefix = "rules_nodejs-0.27.12",
    sha256 = "25dbb063a8a1a2b279d55ba158992ad61eb5266c416c77eb82a7d33b4eac533d",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")

node_repositories(
  package_json = [
    "//internal/json_to_js:package.json",
    "//internal/toml_to_js:package.json",
    "//internal/vue_component:package.json",
    "//experimental/eslint:package.json",
  ],
)

load("//:defs.bzl", "node_contrib_repositories")

node_contrib_repositories()

load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

yarn_install(
    name = "npm",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//examples/babel_library:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//examples/babel_library:yarn.lock",
    data = [
        "@ecosia_bazel_rules_nodejs_contrib//internal/babel_library:package.json",
        "@ecosia_bazel_rules_nodejs_contrib//internal/babel_library:babel.js",
    ],
)

http_archive(
    name = "pax",
    urls = ["https://github.com/Globegitter/pax/archive/001d323ee1374a72ee71ebbaa72f9b032da9ebaf.tar.gz"],
    strip_prefix = "pax-001d323ee1374a72ee71ebbaa72f9b032da9ebaf",
    sha256 = "cf185793dafe4710be266d4aab488114388b0f8bcf74e19df72db6dbb03f0471",
)

http_archive(
    name = "io_bazel_rules_go",
    urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.18.3/rules_go-0.18.3.tar.gz"],
    sha256 = "86ae934bd4c43b99893fc64be9d9fc684b81461581df7ea8fc291c816f5ee8c5",
)

http_archive(
    name = "bazel_gazelle",
    urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/0.17.0/bazel-gazelle-0.17.0.tar.gz"],
    sha256 = "3c681998538231a2d24d0c07ed5a7658cb72bfb5fd4bf9911157c0e9ac6a2687",
)

load("@io_bazel_rules_go//go:deps.bzl", "go_rules_dependencies", "go_register_toolchains")
go_rules_dependencies()
go_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()

load("//examples/nodejs_jest_test:deps.bzl", "nodejs_jest_test_example_dependencies")
nodejs_jest_test_example_dependencies()