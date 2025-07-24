load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("//tools/render:defs.bzl", "render")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@rules___db//:defs.bzl", "RULES")

npm_link_all_packages(name = "node_modules")

[
    render(module = moduledef["name"], doc = doc)
    for moduledef in RULES
    for doc in moduledef["bzl_library_targets"]
]

expand_template(
    name = "nav",
    substitutions = {
        "{{CONTENT}}": "\n".join([
            """
            <div class="module">
                <h2>{module}</h2>
                <ul>
            """.format(module = moduledef["name"]) + "\n".join([
                """
                <li>
                    <a href="/doc.bzl/{module}/{doc_url}" target="content">{doc}</a>
                </li>
                """.format(module = moduledef["name"], doc = doc, doc_url = doc.replace(":", "/"))
                for doc in moduledef["bzl_library_targets"]
            ]) + """
            </ul>
            </div>
            """
            for moduledef in RULES
        ])
    },
    out = "nav.html",
    template = "nav.tmpl.html",
)

copy_to_directory(
    name = "site",
    srcs = [
        "{}.{}.render".format(moduledef["name"], doc.replace(":", "_"))
        for moduledef in RULES
        for doc in moduledef["bzl_library_targets"]
    ] + [
        "index.html",
        "nav.html",
    ] + glob(["_layouts/*", "_includes/*"]),
    testonly = True,
)
