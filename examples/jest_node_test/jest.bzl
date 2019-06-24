load("//:defs.bzl", _jest_node_test = "jest_node_test")

def jest_node_test(name, srcs, deps = [], **kwargs):
    _jest_node_test(
        name = name,
        srcs = srcs,
        deps = deps + [
            "@jest_node_test_example_deps//jest-cli",
            "@jest_node_test_example_deps//fs-extra",
        ],
        config = ":jest.config.js",
        jest = "@jest_node_test_example_deps//jest-cli/bin:jest",
        entry_point = "@jest_node_test_example_deps//:node_modules/jest-cli/bin/jest.js",
        **kwargs
    )
