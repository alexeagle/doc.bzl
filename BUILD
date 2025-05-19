load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@tar.bzl", "tar")

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

# This tar file must conform to these rules:
# https://github.com/actions/upload-pages-artifact/tree/v3/?tab=readme-ov-file#artifact-validation
tar(
    name = "github-pages",
    srcs = [
        "{}.{}.render".format(module, doc.replace(":", "_"))
        for module, doc in DOCS
    ],
    compress = "gzip",
)
