"""Macro to launch the render tool"""
load("@aspect_rules_js//js:defs.bzl", "js_run_binary")
    
def render(module, doc):
    js_run_binary(
        name = "{}.{}.render".format(module, doc.replace(":", "_")),
        srcs = ["@{}//{}.docs-as-proto".format(module, doc)],
        args = ["$(rootpaths {})".format("@{}//{}.docs-as-proto".format(module, doc))],
        env = {"RUNFILES_DIR": "."},
        stdout = "{}/{}.md".format(module, doc.lstrip(":").replace(":", "/")),
        tool = "//tools/render",
    )
