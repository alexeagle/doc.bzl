"""Convert JSON to loadable Starlark constant"""

def _rules_db_impl(rctx):
    database = json.decode(rctx.read(rctx.attr.database))
    rctx.file("BUILD", "# no targets")
    rctx.file("defs.bzl", """\
RULES = {}
    """.format(database['modules']))

rules_db = repository_rule(
    implementation = _rules_db_impl,
    attrs = {
        "database": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
)
