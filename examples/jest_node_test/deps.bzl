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

def jest_node_test_example_dependencies():
    yarn_install(
        name = "jest_node_test_example_deps",
        package_json = "@ecosia_bazel_rules_nodejs_contrib//examples/jest_node_test:package.json",
        yarn_lock = "@ecosia_bazel_rules_nodejs_contrib//examples/jest_node_test:yarn.lock",
        exclude_packages = [],
        quiet = False,
        data = [
            "//:tools/patches/@jest+core+24.7.1.patch",
            "//:tools/patches/@jest+transform+24.7.1.patch",
            "//:tools/patches/babel-plugin-istanbul+5.1.2.patch",
            "//:tools/patches/istanbul-api+2.1.5.patch",
            "//:tools/patches/jest-cli+24.7.1.patch",
            "//:tools/patches/jest-config+24.7.1.patch",
            "//:tools/patches/jest-haste-map+24.7.1.patch",
            "//:tools/patches/jest-resolve+24.7.1.patch",
            "//:tools/patches/jest-runtime+24.7.1.patch",
        ],
    )
