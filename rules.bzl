"""Convert JSON to loadable Starlark constant"""

def _rules_db_impl(rctx):
    database = json.decode(rctx.read(rctx.attr.database))
    blocklist = rctx.read(rctx.attr.blocklist).splitlines()
    modules = database['modules']
    for module in modules:
        module['bzl_library_targets'] = [target for target in module['bzl_library_targets'] if "@{}//{}".format(module['name'], target) not in blocklist]
        
    rctx.file("BUILD", "# no targets")
    rctx.file("defs.bzl", """\
RULES = {}
    """.format(modules))

rules_db = repository_rule(
    implementation = _rules_db_impl,
    attrs = {
        "blocklist": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "database": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
)
