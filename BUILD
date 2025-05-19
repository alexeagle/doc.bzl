load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

DOCS = {
    "JavaScript": [
        ("aspect_rules_js", "js:defs"),
        ("aspect_rules_js", "npm:defs"),
        ("aspect_rules_swc", "swc:defs"),
        ("aspect_rules_ts", "ts:defs"),
        ("aspect_rules_jasmine", "jasmine:defs"),
    ],
    "Docker / OCI": [
        ("rules_oci", "oci:defs"),
    ],
    "Linting": [
        ("aspect_rules_lint", "lint:ruff"),
    ],
    "Testing": [
        ("aspect_bazel_lib", "lib:bats"),
    ],
    "Utilities": [
        ("tar.bzl", "tar:tar"),
        ("tar.bzl", "tar:mtree"),
    ],
}

[
    render(module = module, doc = doc)
    for doclist in DOCS.values()
    for module, doc in doclist
]

write_file(
    name = "index",
    content = [
        "# Bazel Rules Documentation",
    ] + [
        "## {}\n{}".format(category, "\n".join([
            "- [{}](/doc.bzl/{}/{}.md)".format(doc, module, doc.replace(":", "/"))
            for module, doc in doclist
        ]))
        for category, doclist in DOCS.items()
    ],
    out = "index.md",
)

copy_to_directory(
    name = "site",
    srcs = [
        "{}.{}.render".format(module, doc.replace(":", "_"))
        for doclist in DOCS.values()
        for module, doc in doclist
    ] + [
        "_config.yml", 
        "index.md",
    ],
)
