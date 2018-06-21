# JS rules for Bazel
Ecosia specific JS Bazel rules to be used with the NodeJS rules

## Setup

```
# These rules depend on running Node.js
http_archive(
    name = "build_bazel_rules_nodejs",
    url = "https://github.com/bazelbuild/rules_nodejs/archive/0.10.0.zip",
    strip_prefix = "rules_nodejs-0.10.0",
    sha256 = "2f77623311da8b5009b1c7eade12de8e15fa3cd2adf9dfcc9f87cb2082b2211f",
)

http_archive(
    name = "ecosia_bazel_rules_nodejs_contrib",
    url = "",
    sha256 = "",
    strip_prefix = "bazel_rules_nodejs_contrib-0.0.3",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")

# Point to the package.json file so Bazel can run the package manager for you.
node_repositories(package_json = ["//:package.json"])

load("@ecosia_bazel_rules_nodejs_contrib//:defs.bzl", "node_contrib_repositories")

node_contrib_repositories()
```

## Rules
