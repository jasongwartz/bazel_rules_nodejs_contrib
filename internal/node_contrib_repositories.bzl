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


load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

def node_contrib_repositories():

  yarn_install(
    name = "vue_component_deps",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//internal/vue_component:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//internal/vue_component:yarn.lock",
    exclude_packages = [],
    symlink_node_modules = False,
  )

  yarn_install(
    name = "toml_to_js_deps",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//internal/toml_to_js:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//internal/toml_to_js:yarn.lock",
    exclude_packages = [],
    symlink_node_modules = False,
  )

  yarn_install(
    name = "json_to_js_deps",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//internal/json_to_js:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//internal/json_to_js:yarn.lock",
    exclude_packages = [],
    symlink_node_modules = False,
  )

  yarn_install(
    name = "eslint_deps",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//experimental/eslint:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//experimental/eslint:yarn.lock",
    exclude_packages = [],
    symlink_node_modules = False,
  )

  yarn_install(
    name = "nuxt_build",
    package_json = "@ecosia_bazel_rules_nodejs_contrib//experimental/nuxt_build:package.json",
    yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//experimental/nuxt_build:yarn.lock",
    exclude_packages = [],
    symlink_node_modules = False,
  )
