# JS rules for Bazel
Ecosia specific JS Bazel rules to be used with the NodeJS rules

## Setup

```py
# These rules depend on running Node.js
http_archive(
    name = "build_bazel_rules_nodejs",
    urls = ["https://github.com/bazelbuild/rules_nodejs/archive/0.27.12.tar.gz"],
    strip_prefix = "rules_nodejs-0.27.12",
    sha256 = "25dbb063a8a1a2b279d55ba158992ad61eb5266c416c77eb82a7d33b4eac533d",
)

http_archive(
    name = "ecosia_bazel_rules_nodejs_contrib",
    url = "https://github.com/ecosia/bazel_rules_nodejs_contrib/archive/b91f21203671d63f344b5ad6984382b338c66b18.zip",
    strip_prefix = "bazel_rules_nodejs_contrib-b91f21203671d63f344b5ad6984382b338c66b18",
    sha256 = "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")

# Point to the package.json file so Bazel can run the package manager for you.
node_repositories(package_json = ["//:package.json"])

# This loads the dependencies for the rules in this repository
load("@ecosia_bazel_rules_nodejs_contrib//:defs.bzl", "node_contrib_repositories")

node_contrib_repositories()
```

## Rules

For usage of each rule have a look in the examples directory.

### json_to_js

Converts json files to treeshakable ES modules

`json_to_js(name, srcs)`

### toml_to_js

Converts toml files to treeshakable ES modules

`toml_to_js(name, srcs, strict)`

### vue_component

Converts a vue component to an ES module with the css injected into the js.

`vue_component(name, src)`

### js_library

A generic js_library rule that provides transitive dependency support for `bazelbuild/rules_nodejs` as well as some basic interoperability with `ts_devserver`.

`js_library(name, srcs, deps, module_name, module_root)`

### babel_library

This rule provides compilation support with babel as well as transitive dependency support for `bazelbuild/rules_nodejs` and interoperability with `ts_devserver`.  The default label for the `babel` binary is `@npm//@bazel/babel/bin:babel` and if no custom `babelrc` is provided it defaults to `@babel/preset-env` with umd compilation the way `ts_devserver` expects.

`babel_library(name, srcs, deps, data, module_name, module_root, babel, babelrc)`

## Build file generation

Build file generation is provided as a plugin for [gazelle](https://github.com/bazelbuild/bazel-gazelle) and still WIP and to a certain degree coupled to our internal js setup. It should not be difficult to extend / make it more generic though. It makes use of the `js_library` and `jest_node_test` provided in these rules.

To setup the gazlle plugin follow the installation instructions provided by the repository and additionally add the following:

```py
gazelle(
    name = "gazelle",
    gazelle = ":gazelle_js",
)

gazelle_binary(
    name = "gazelle_js",
    # keep
    languages = DEFAULT_LANGUAGES + [
        "@ecosia_bazel_rules_nodejs_contrib//gazelle:go_default_library",
    ],
    visibility = [
        "//visibility:public",
    ],
)
```

## Contributions

The code in this repository is not actively supported / developed as these rules have currently only been used for experimentation and bazel is being evaluated for internal use. PRs and bug fixes would most likely be accepted though.
