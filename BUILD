load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
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
    "Bash / Shell": [
        ("rules_shell", "shell:rules_bzl"),
        ("aspect_bazel_lib", "lib:bats"),
    ],
    "Protobuf / gRPC": [
        # ("toolchains_protoc", "protoc:extensions"),
    ],
    "C / C++": [
        # ("toolchains_llvm", "llvm:llvm"),
    ],
    "Docker / OCI": [
        ("rules_oci", "oci:defs"),
    ],
    "Linting": [
        ("aspect_rules_lint", "lint:ruff"),
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

expand_template(
    name = "index",
    substitutions = {
        "{{CONTENT}}": "\n".join([
            """
            <div class="category">
                <h2>{category}</h2>
                <ul>
            """.format(category = category) + "\n".join([
                """
                <li>
                    <a href="/doc.bzl/{module}/{doc}.md">{doc}</a>
                </li>
                """.format(module = module, doc = doc.replace(":", "/"))
                for module, doc in doclist
            ]) + """
            </ul>
            </div>
            """
            for category, doclist in DOCS.items()
        ])
    },
    out = "index.html",
    template = "index.tmpl.html",
)

copy_to_directory(
    name = "site",
    srcs = [
        "{}.{}.render".format(module, doc.replace(":", "_"))
        for doclist in DOCS.values()
        for module, doc in doclist
    ] + [
        "_config.yml",
        "index.html",
    ],
)
