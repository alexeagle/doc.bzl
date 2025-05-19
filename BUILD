load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

DOCS = [
    ("aspect_bazel_lib", "lib:bats"),
    ("aspect_rules_js", "js:defs"),
    ("aspect_rules_js", "npm:defs"),
    ("aspect_rules_lint", "lint:ruff"),
    ("aspect_rules_swc", "swc:defs"),
    ("aspect_rules_ts", "ts:defs"),
    ("aspect_rules_jasmine", "jasmine:defs"),
    ("rules_oci", "oci:defs"),
    ("tar.bzl", "tar:tar"),
    ("tar.bzl", "tar:mtree"),
]

[
    render(module = module, doc = doc)
    for module, doc in DOCS
]

write_file(
    name = "index",
    content = [
        "- [{}](/doc.bzl/{}/{}.md)".format(doc, module, doc.replace(":", "/"))
        for module, doc in DOCS
    ],
    out = "index.md",
)

copy_to_directory(
    name = "site",
    srcs = [
        "{}.{}.render".format(module, doc.replace(":", "_"))
        for module, doc in DOCS
    ] + ["_config.yml", "index.md"],
)
