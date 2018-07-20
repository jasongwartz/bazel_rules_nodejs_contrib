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
    name = "build_bazel_rules_nodejs",
    url = "https://github.com/bazelbuild/rules_nodejs/archive/f481a1abf54b1dee887329ef1ea8a0bb1e5f2bb1.tar.gz",
    strip_prefix = "rules_nodejs-f481a1abf54b1dee887329ef1ea8a0bb1e5f2bb1",
    sha256 = "8d92afed94270b11bb50609bd3431ab8770f5daa64211e96aa353118b4226269",
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

http_archive(
    name = "pax",
    url = "https://github.com/globegitter/pax/archive/0a71acad5091d92b8fdc8c0c135be0f4447b9749.tar.gz",
    strip_prefix = "pax-0a71acad5091d92b8fdc8c0c135be0f4447b9749",
    sha256 = "b168bc0ea81cde55f42b2e3028c42db9da5e2197f3bfc80365d617cc11966cee",
)


http_archive(
    name = "io_bazel_rules_go",
    urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.13.0/rules_go-0.13.0.tar.gz"],
    sha256 = "ba79c532ac400cefd1859cbc8a9829346aa69e3b99482cd5a54432092cbc3933",
)

http_archive(
    name = "bazel_gazelle",
    urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/0.13.0/bazel-gazelle-0.13.0.tar.gz"],
    sha256 = "bc653d3e058964a5a26dcad02b6c72d7d63e6bb88d94704990b908a1445b8758",
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")
go_rules_dependencies()
go_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()
