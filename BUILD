load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

DOCS = {
    "JavaScript / TypeScript": [
        ("aspect_rules_js", "js:defs"),
        ("aspect_rules_js", "npm:defs"),
        ("aspect_rules_swc", "swc:defs"),
        ("aspect_rules_ts", "ts:defs"),
        ("aspect_rules_esbuild", "esbuild:defs"),
        ("aspect_rules_jasmine", "jasmine:defs"),
        ("rules_angular", "src/architect:ng_application"),
        ("rules_angular", "src/architect:ng_library"),
        ("rules_angular", "src/architect:ng_test"),
    ],
    "Bash / Shell": [
        ("rules_shell", "shell:rules_bzl"),
        ("aspect_bazel_lib", "lib:bats"),
    ],
    "Rust": [
        # FIXME
        # ERROR: external/rules_rust+/rust/BUILD.bazel:23:12: in deps attribute of starlark_doc_extract rule @@rules_rust+//rust:bzl_lib.doc_extract:
        # missing bzl_library targets for Starlark module(s) @rules_rust//rust:toolchain.bzl. 
        # ("rules_rust", "rust:bzl_lib"),
    ],
    "Go": [
        ("rules_go", "go:def"),
    ],
    "C / C++": [
        # ("toolchains_llvm", "llvm:llvm"),
    ],
    "Docker / OCI": [
        ("rules_oci", "oci:defs"),
        ("rules_distroless", "distroless:defs"),
        ("rules_apko", "apko:defs"),
    ],
    "Linting / Formatting": [
        ("aspect_rules_lint", "format:defs"),
        ("aspect_rules_lint", "lint:buf"),
        ("aspect_rules_lint", "lint:checkstyle"),
        ("aspect_rules_lint", "lint:eslint"),
        ("aspect_rules_lint", "lint:keep_sorted"),
        ("aspect_rules_lint", "lint:ktlint"),
        ("aspect_rules_lint", "lint:lint_test"),
        ("aspect_rules_lint", "lint:ruff"),
        ("aspect_rules_lint", "lint:shellcheck"),
        ("aspect_rules_lint", "lint:stylelint"),   
    ],
    "Utilities": [
        ("aspect_bazel_lib", "lib:expand_template"),
        ("aspect_bazel_lib", "lib:write_source_files"),
        ("awk.bzl", "awk:awk"),
        ("bazel_env.bzl", ":bazel_env"),
        ("jq.bzl", "jq:jq"),
        ("tar.bzl", "tar:tar"),
        ("tar.bzl", "tar:mtree"),
        ("yq.bzl", "yq:yq"),
    ],
}

[
    render(module = module, doc = doc)
    for doclist in DOCS.values()
    for module, doc in doclist
]

expand_template(
    name = "nav",
    substitutions = {
        "{{CONTENT}}": "\n".join([
            """
            <div class="category">
                <h2>{category}</h2>
                <ul>
            """.format(category = category) + "\n".join([
                """
                <li>
                    <a href="/doc.bzl/{module}/{doc}.md" target="content">{doc}</a>
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
    out = "nav.html",
    template = "nav.tmpl.html",
)

expand_template(
    name = "index",
    substitutions = {},
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
        "Gemfile",
        "_config.yml",
        "index.html",
        "nav.html",
    ],
)
