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
  ],
)

load("//:defs.bzl", "node_contrib_repositories")

node_contrib_repositories()

http_archive(
    name = "pax",
    url = "https://github.com/globegitter/pax/archive/1403cb587ad0cc8e53973d3615397f3b43d4e527.tar.gz",
    strip_prefix = "pax-1403cb587ad0cc8e53973d3615397f3b43d4e527",
    sha256 = "d51b74178bc97bc63a3c610b28ace25c2f28b44774e746b5f0714beebbd5959a",
)
