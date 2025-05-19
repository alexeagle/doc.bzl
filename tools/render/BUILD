load("@aspect_rules_js//js:defs.bzl", "js_binary")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

ts_project(
    name = "starlark",
    srcs = [
        "fs.mts",
        "handlebars.mts",
        "index.mts",
    ],
    data = ["//tools/render/templates"],
    source_map = True,
    deps = [
        ":node_modules/@bazel/runfiles",
        ":node_modules/@buf/bazel_bazel.bufbuild_es",
        ":node_modules/@bufbuild/protobuf",
        ":node_modules/@types/node",
        ":node_modules/handlebars",
    ],
)

js_binary(
    name = "render",
    data = [":starlark"],
    entry_point = "index.mjs",
    visibility = ["//:__subpackages__"],
)
