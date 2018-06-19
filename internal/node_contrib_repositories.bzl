load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

def node_contrib_repositories():

  yarn_install(
    name = "vue_component_deps",
    package_json = "//tools/rules/vue_component:package.json",
    yarn_lock = "//tools/rules/vue_component:yarn.lock",
  )

  yarn_install(
    name = "toml_to_js_deps",
    package_json = "//tools/rules/toml_to_js:package.json",
    yarn_lock = "//tools/rules/toml_to_js:yarn.lock",
  )

  yarn_install(
    name = "json_to_js_deps",
    package_json = "//tools/rules/json_to_js:package.json",
    yarn_lock = "//tools/rules/json_to_js:yarn.lock",
  )
