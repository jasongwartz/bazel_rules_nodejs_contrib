# JS rules for Bazel
Ecosia specific JS Bazel rules to be used with the NodeJS rules

## Setup

```py
# These rules depend on running Node.js
http_archive(
    name = "build_bazel_rules_nodejs",
    url = "https://github.com/bazelbuild/rules_nodejs/archive/0.10.0.zip",
    strip_prefix = "rules_nodejs-0.10.0",
    sha256 = "2f77623311da8b5009b1c7eade12de8e15fa3cd2adf9dfcc9f87cb2082b2211f",
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


## Contributions

The code in this repository is not actively supported / developed as these rules have currently only been used for experimentation and bazel is being evaluated for internal use. PRs and bug fixes would most likely be accepted though.
