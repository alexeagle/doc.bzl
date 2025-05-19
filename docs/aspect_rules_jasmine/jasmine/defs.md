<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

rules_jasmine public API

Rules
=====


## jasmine_test_rule

Runs tests in NodeJS using the Jasmine test runner.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### chdir

Optional string.
Default: `""`



Working directory to run the binary or test in, relative to the workspace.

By default, `js_binary` runs in the root of the output tree.

To run in the directory containing the `js_binary` use

    chdir = package_name()

(or if you're in a macro, use `native.package_name()`)

WARNING: this will affect other paths passed to the program, either as arguments or in configuration files,
which are workspace-relative.

You may need `../../` segments to re-relativize such paths to the new working directory.
In a `BUILD` file you could do something like this to point to the output path:

```python
js_binary(
    ...
    chdir = package_name(),
    # ../.. segments to re-relative paths from the chdir back to workspace;
    # add an additional 3 segments to account for running js_binary running
    # in the root of the output tree
    args = ["/".join([".."] * len(package_name().split("/"))) + "$(rootpath //path/to/some:file)"],
)
```


### data

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Runtime dependencies of the program.

The transitive closure of the `data` dependencies will be available in
the .runfiles folder for this binary/test.

NB: `data` files are copied to the Bazel output tree before being passed
as inputs to runfiles. See `copy_data_to_bin` docstring for more info.


### entry_point

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




The main script which is evaluated by node.js.

This is the module referenced by the `require.main` property in the runtime.

This must be a target that provides a single file or a `DirectoryPathInfo`
from `@aspect_bazel_lib//lib::directory_path.bzl`.

See https://github.com/bazel-contrib/bazel-lib/blob/main/docs/directory_path.md
for more info on creating a target that provides a `DirectoryPathInfo`.


### enable_runfiles

Required boolean.




Whether runfiles are enabled in the current build configuration.

Typical usage of this rule is via a macro which automatically sets this
attribute based on a `config_setting` rule.


### env

Optional <a href="https://bazel.build/docs/skylark/lib/dict.html">dictionary: String → String</a>.
Default: `{}`



Environment variables of the action.

Subject to [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution if `expand_env` is set to True.


### expand_args

Optional boolean.
Default: `True`



Enables [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution for `fixed_args`.

This comes at some analysis-time cost even for a set of args that does not have any expansions.


### expand_env

Optional boolean.
Default: `True`



Enables [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution for `env`.

This comes at some analysis-time cost even for a set of envs that does not have any expansions.


### fixed_args

Optional list of strings.
Default: `[]`



Fixed command line arguments to pass to the Node.js when this
binary target is executed.

Subject to [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution if `expand_args` is set to True.

Unlike the built-in `args`, which are only passed to the target when it is
executed either by the `bazel run` command or as a test, `fixed_args` are baked
into the generated launcher script so are always passed even when the binary
target is run outside of Bazel directly from the launcher script.

`fixed_args` are passed before the ones specified in `args` and before ones
that are specified on the `bazel run` or `bazel test` command line.

See https://bazel.build/reference/be/common-definitions#common-attributes-binaries
for more info on the built-in `args` attribute.


### node_options

Optional list of strings.
Default: `[]`



Options to pass to the node invocation on the command line.

https://nodejs.org/api/cli.html

These options are passed directly to the node invocation on the command line.
Options passed here will take precendence over options passed via
the NODE_OPTIONS environment variable. Options passed here are not added
to the NODE_OPTIONS environment variable so will not be automatically
picked up by child processes that inherit that enviroment variable.


### expected_exit_code

Optional integer.
Default: `0`



The expected exit code.

Can be used to write tests that are expected to fail.


### log_level

Optional string.
Default: `"error"`



Set the logging level.

Log from are written to stderr. They will be supressed on success when running as the tool
of a js_run_binary when silent_on_success is True. In that case, they will be shown
only on a build failure along with the stdout & stderr of the node tool being run.

Log levels: fatal, error, warn, info, debug


### patch_node_fs

Optional boolean.
Default: `True`



Patch the to Node.js `fs` API (https://nodejs.org/api/fs.html) for this node program
to prevent the program from following symlinks out of the execroot, runfiles and the sandbox.

When enabled, `js_binary` patches the Node.js sync and async `fs` API functions `lstat`,
`readlink`, `realpath`, `readdir` and `opendir` so that the node program being
run cannot resolve symlinks out of the execroot and the runfiles tree. When in the sandbox,
these patches prevent the program being run from resolving symlinks out of the sandbox.

When disabled, node programs can leave the execroot, runfiles and sandbox by following symlinks
which can lead to non-hermetic behavior.


### include_sources

Optional boolean.
Default: `True`



When True, `sources` from `JsInfo` providers in `data` targets are included in the runfiles of the target.


### include_transitive_sources

Optional boolean.
Default: `True`



When True, `transitive_sources` from `JsInfo` providers in `data` targets are included in the runfiles of the target.


### include_types

Optional boolean.
Default: `False`



When True, `types` from `JsInfo` providers in `data` targets are included in the runfiles of the target.

Defaults to False since types are generally not needed at runtime and introducing them could slow down developer round trip
time due to having to generate typings on source file changes.

NB: These are types from direct `data` dependencies only. You may also need to set `include_transitive_types` to True.


### include_transitive_types

Optional boolean.
Default: `False`



When True, `transitive_types` from `JsInfo` providers in `data` targets are included in the runfiles of the target.

Defaults to False since types are generally not needed at runtime and introducing them could slow down developer round trip
time due to having to generate typings on source file changes.


### include_npm_sources

Optional boolean.
Default: `True`



When True, files in `npm_sources` from `JsInfo` providers in `data` targets are included in the runfiles of the target.

`transitive_files` from `NpmPackageStoreInfo` providers in `data` targets are also included in the runfiles of the target.


### preserve_symlinks_main

Optional boolean.
Default: `True`



When True, the --preserve-symlinks-main flag is passed to node.

This prevents node from following an ESM entry script out of runfiles and the sandbox. This can happen for `.mjs`
ESM entry points where the fs node patches, which guard the runfiles and sandbox, are not applied.
See https://github.com/aspect-build/rules_js/issues/362 for more information. Once #362 is resolved,
the default for this attribute can be set to False.

This flag was added in Node.js v10.2.0 (released 2018-05-23). If your node toolchain is configured to use a
Node.js version older than this you'll need to set this attribute to False.

See https://nodejs.org/api/cli.html#--preserve-symlinks-main for more information.


### no_copy_to_bin

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



List of files to not copy to the Bazel output tree when `copy_data_to_bin` is True.

This is useful for exceptional cases where a `copy_to_bin` is not possible or not suitable for an input
file such as a file in an external repository. In most cases, this option is not needed.
See `copy_data_to_bin` docstring for more info.


### copy_data_to_bin

Optional boolean.
Default: `True`



When True, `data` files and the `entry_point` file are copied to the Bazel output tree before being passed
as inputs to runfiles.

Defaults to True so that a `js_binary` with the default value is compatible with `js_run_binary` with
`use_execroot_entry_point` set to True, the default there.

Setting this to False is more optimal in terms of inputs, but there is a yet unresolved issue of ESM imports
skirting the node fs patches and escaping the sandbox: https://github.com/aspect-build/rules_js/issues/362.
This is hit in some popular test runners such as mocha, which use native `import()` statements
(https://github.com/aspect-build/rules_js/pull/353). When set to False, a program such as mocha that uses ESM
imports may escape the execroot by following symlinks into the source tree. When set to True, such a program
would escape the sandbox but will end up in the output tree where `node_modules` and other inputs required
will be available.


### include_npm

Optional boolean.
Default: `False`



When True, npm is included in the runfiles of the target.

An npm binary is also added on the PATH so tools can spawn npm processes. This is a bash script
on Linux and MacOS and a batch script on Windows.

A minimum of rules_nodejs version 5.7.0 is required which contains the Node.js toolchain changes
to use npm.


### node_toolchain

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



The Node.js toolchain to use for this target.

See https://bazel-contrib.github.io/rules_nodejs/Toolchains.html

Typically this is left unset so that Bazel automatically selects the right Node.js toolchain
for the target platform. See https://bazel.build/extending/toolchains#toolchain-resolution
for more information.


### junit_reporter

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`






### config

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`








# Macros and Functions


## jasmine_test

Runs jasmine under `bazel test`

 

### name

Required. 

A unique name for this target.





### node_modules

Required. 

Label pointing to the linked node_modules target where jasmine is linked, e.g. `//:node_modules`.

`jasmine` must be linked into the node_modules supplied.
`jasmine-reporters` is also required by default when jasmine_reporters is True
`jasmine-core` is required when using sharding.





### jasmine_reporters

Optional. Default: `True`

Whether `jasmine-reporters` is present in the supplied node_modules tree.

When enabled, adds a custom reporter to output junit XML to the path where Bazel expects to find it.





### config

Optional. Default: `None`

jasmine config file. See: https://jasmine.github.io/setup/nodejs.html#configuration





### timeout

Optional. Default: `None`

standard attribute for tests. Defaults to "short" if both timeout and size are unspecified.





### size

Optional. Default: `None`

standard attribute for tests





### data

Optional. Default: `[]`

Runtime dependencies that Jasmine should be able to read.

This should include all test files, configuration files & files under test.





### kwargs

Optional. 

Additional named parameters from `js_test`.
See [js_test docs](https://github.com/aspect-build/rules_js/blob/main/docs/js_binary.md#js_test)







