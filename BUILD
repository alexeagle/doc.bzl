load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

DOCS = [
    ("aspect_bazel_lib", "lib:bats"),
    ("aspect_rules_js", "js:defs"),
    ("aspect_rules_js", "npm:defs"),
    ("aspect_rules_swc", "swc:defs"),
    ("tar.bzl", "tar:tar"),
    ("tar.bzl", "tar:mtree"),
]

[
    render(module = module, doc = doc)
    for module, doc in DOCS
]

copy_to_directory(
    name = "site",
    srcs = [
        "{}.{}.render".format(module, doc.replace(":", "_"))
        for module, doc in DOCS
    ],
)
