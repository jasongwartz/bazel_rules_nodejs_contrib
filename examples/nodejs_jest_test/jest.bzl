load("//:defs.bzl", _nodejs_jest_test = "nodejs_jest_test")

def nodejs_jest_test(name, srcs, deps=[], **kwargs):
    _nodejs_jest_test(
        name = name,
        srcs = srcs,
        deps = deps + [
            "@nodejs_jest_test_example_deps//jest-cli", 
            "@nodejs_jest_test_example_deps//fs-extra",
        ],
        **kwargs
    )
