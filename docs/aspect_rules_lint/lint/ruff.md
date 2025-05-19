<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

API for declaring a Ruff lint aspect that visits py_library rules.

Typical usage:

```
load("@aspect_rules_lint//lint:ruff.bzl", "ruff_aspect")

ruff = ruff_aspect(
    binary = "@multitool//tools/ruff",
    configs = "@@//:.ruff.toml",
)
```

## Using a specific ruff version

In `WORKSPACE`, fetch the desired version from https://github.com/astral-sh/ruff/releases

```starlark
load("@aspect_rules_lint//lint:ruff.bzl", "fetch_ruff")

# Specify a tag from the ruff repository
fetch_ruff("v0.4.10")
```

In `tools/lint/BUILD.bazel`, select the tool for the host platform:

```starlark
# Note: this won't interact properly with the --platform flag, see
# https://github.com/aspect-build/rules_lint/issues/389
alias(
    name = "ruff",
    actual = select({
        "@bazel_tools//src/conditions:linux_x86_64": "@ruff_x86_64-unknown-linux-gnu//:ruff",
        "@bazel_tools//src/conditions:linux_aarch64": "@ruff_aarch64-unknown-linux-gnu//:ruff",
        "@bazel_tools//src/conditions:darwin_arm64": "@ruff_aarch64-apple-darwin//:ruff",
        "@bazel_tools//src/conditions:darwin_x86_64": "@ruff_x86_64-apple-darwin//:ruff",
        "@bazel_tools//src/conditions:windows_x64": "@ruff_x86_64-pc-windows-msvc//:ruff.exe",
    }),
)
```

Finally, reference this tool alias rather than the one from `@multitool`:

```starlark
ruff = lint_ruff_aspect(
    binary = "@@//tools/lint:ruff",
    ...
)
```



# Macros and Functions


## ruff_action

Run ruff as an action under Bazel.

Ruff will select the configuration file to use for each source file, as documented here:
https://docs.astral.sh/ruff/configuration/#config-file-discovery

Note: all config files are passed to the action.
This means that a change to any config file invalidates the action cache entries for ALL
ruff actions.

However this is needed because:

1. ruff has an `extend` field, so it may need to read more than one config file
2. ruff's logic for selecting the appropriate config needs to read the file content to detect
  a `[tool.ruff]` section.


 

### ctx

Required. 

Bazel Rule or Aspect evaluation context





### executable

Required. 

label of the the ruff program





### srcs

Required. 

python files to be linted





### config

Required. 

labels of ruff config files (pyproject.toml, ruff.toml, or .ruff.toml)





### stdout

Required. 

output file of linter results to generate





### exit_code

Optional. Default: `None`

output file to write the exit code.
If None, then fail the build when ruff exits non-zero.
See https://github.com/astral-sh/ruff/blob/dfe4291c0b7249ae892f5f1d513e6f1404436c13/docs/linter.md#exit-codes





### env

Optional. Default: `{}`

environment variaables for ruff





## ruff_fix

Create a Bazel Action that spawns ruff with --fix.

 

### ctx

Required. 

an action context OR aspect context





### executable

Required. 

struct with _ruff and _patcher field





### srcs

Required. 

list of file objects to lint





### config

Required. 

labels of ruff config files (pyproject.toml, ruff.toml, or .ruff.toml)





### patch

Required. 

output file containing the applied fixes that can be applied with the patch(1) command.





### stdout

Required. 

output file of linter results to generate





### exit_code

Required. 

output file to write the exit code





### env

Optional. Default: `{}`

environment variaables for ruff





## lint_ruff_aspect

A factory function to create a linter aspect.

Attrs:
    binary: a ruff executable
    configs: ruff config file(s) (`pyproject.toml`, `ruff.toml`, or `.ruff.toml`)
    rule_kinds: which [kinds](https://bazel.build/query/language#kind) of rules should be visited by the aspect

 

### binary

Required. 







### configs

Required. 







### rule_kinds

Optional. Default: `["py_binary", "py_library", "py_test"]`







## fetch_ruff

A repository macro used from WORKSPACE to fetch ruff binaries.

Allows the user to select a particular ruff version, rather than get whatever is pinned in the `multitool.lock.json` file.


 

### tag

Required. 

a tag of ruff that we have mirrored, e.g. `v0.1.0`







