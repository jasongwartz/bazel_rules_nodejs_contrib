# JS rules for Bazel
Ecosia specific JS Bazel rules to be used with the NodeJS rules

## Setup

```py
# These rules depend on running Node.js
http_archive(
    name = "build_bazel_rules_nodejs",
    urls = ["https://github.com/bazelbuild/rules_nodejs/archive/0.29.0.tar.gz"],
    strip_prefix = "rules_nodejs-0.29.0",
    sha256 = "86a5140bd330b45640e44d3f43b6d9f6c75ab560ac9b4aba1e5c83a18e3ee6b1",
)

http_archive(
    name = "ecosia_bazel_rules_nodejs_contrib",
    urls = ["https://github.com/ecosia/bazel_rules_nodejs_contrib/archive/03d2aaa741998b86eaec9d9339e9e70f6b2814c8.tar.gz"],
    strip_prefix = "bazel_rules_nodejs_contrib-03d2aaa741998b86eaec9d9339e9e70f6b2814c8",
    sha256 = "0cfa7423a513d166ef11b70c94d928c3c797fa1e34cba8374817bd9d3781e66d",
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

### js_import

Provides transitive dependcy support for custom files to be imported in js. Like svg or proto files that will get compiled to js by an upstream rule. This exists mostly for compatibility and migration reasons, as ideally each of these files would have ther own `x_to_js` or similar rules.

`js_import(name, srcs)`

### vue_component

Converts a vue component to an ES module with the css injected into the js.

`vue_component(name, src)`

### js_library

A generic js_library rule that provides transitive dependency support for `bazelbuild/rules_nodejs` as well as some basic interoperability with `ts_devserver`.

`js_library(name, srcs, deps, module_name, module_root)`

### babel_library

This rule provides compilation support with babel as well as transitive dependency support for `bazelbuild/rules_nodejs` and interoperability with `ts_devserver`.  

The default label for the `babel` binary is `@npm//@bazel/babel/bin:babel` as it is eventually expected to be a hosted package. For now you can either create a `nodejs_binary` including the `babel.js` in your workspace or add a `file:` dependency into your `package.json` similar to the example provided here. If no custom `babelrc` is provided it defaults to `@babel/preset-env` with umd compilation the way `ts_devserver` expects.

`babel_library(name, srcs, deps, data, module_name, module_root, babel, babelrc)`

## Build file generation

Build file generation is provided as a plugin for [gazelle](https://github.com/bazelbuild/bazel-gazelle) and still WIP and to a certain degree coupled to our internal js setup. It should not be difficult to extend / make it more generic though. It makes use of the `js_library` and `jest_node_test` provided in these rules.

To setup the gazlle plugin follow the installation instructions provided by the repository and additionally add the following to your root level `BUILD.bazel`:

```py
load("@bazel_gazelle//:def.bzl", "DEFAULT_LANGUAGES", "gazelle", "gazelle_binary")

# gazelle:exclude node_modules

gazelle(
    name = "gazelle",
    gazelle = ":gazelle_js",
)

gazelle_binary(
    name = "gazelle_js",
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
