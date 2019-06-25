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

workspace(
    name = "ecosia_bazel_rules_nodejs_contrib",
    managed_directories = {
        "@npm": ["examples/babel_library/node_modules"],
        "@jest_node_test_example_deps": ["examples/jest_node_test/node_modules"],
        "@nodejs_jest_test_example_deps": ["examples/nodejs_jest_test/node_modules"],
        "@vue_component_deps": ["internal/vue_component/node_modules"],
        "@toml_to_js_deps": ["examples/toml_to_js/node_modules"],
        "@json_to_js_deps": ["internal/json_to_js/node_modules"],
        "@eslint_deps": ["experimental/eslint/node_modules"],
        "@nuxt_build": ["experimental/nuxt_build/node_modules"],
    },
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
    strip_prefix = "bazel-skylib-0.8.0",
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz"],
)

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "0c78dd9ca95d0eedb790e11550c3ee6412b585f6d4eae2c2250d2d7511d43cd9",
    strip_prefix = "rules_nodejs-0.32.2",
    urls = ["https://github.com/bazelbuild/rules_nodejs/archive/0.32.2.tar.gz"],
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories", "yarn_install")

node_repositories(
    package_json = [
        "//internal/json_to_js:package.json",
        "//internal/toml_to_js:package.json",
        "//internal/vue_component:package.json",
        "//experimental/eslint:package.json",
    ],
)

load("//:defs.bzl", "node_contrib_repositories")

node_contrib_repositories(
    symlink_node_modules = True,
)

yarn_install(
    name = "npm",
    data = [
        "@ecosia_bazel_rules_nodejs_contrib//internal/babel_library:babel.js",
        "@ecosia_bazel_rules_nodejs_contrib//internal/babel_library:package.json",
    ],
    exclude_packages = [],
    package_json = "@ecosia_bazel_rules_nodejs_contrib//examples/babel_library:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//examples/babel_library:yarn.lock",
)

http_archive(
    name = "pax",
    sha256 = "cf185793dafe4710be266d4aab488114388b0f8bcf74e19df72db6dbb03f0471",
    strip_prefix = "pax-001d323ee1374a72ee71ebbaa72f9b032da9ebaf",
    urls = ["https://github.com/Globegitter/pax/archive/001d323ee1374a72ee71ebbaa72f9b032da9ebaf.tar.gz"],
)

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "f04d2373bcaf8aa09bccb08a98a57e721306c8f6043a2a0ee610fd6853dcde3d",
    urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.18.6/rules_go-0.18.6.tar.gz"],
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "3c681998538231a2d24d0c07ed5a7658cb72bfb5fd4bf9911157c0e9ac6a2687",
    urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/0.17.0/bazel-gazelle-0.17.0.tar.gz"],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("//examples/jest_node_test:deps.bzl", "jest_node_test_example_dependencies")

jest_node_test_example_dependencies()

load("//examples/nodejs_jest_test:deps.bzl", "nodejs_jest_test_example_dependencies")

nodejs_jest_test_example_dependencies()
