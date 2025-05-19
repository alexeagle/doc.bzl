<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

API for running the SWC cli under Bazel

The simplest usage relies on the `swcrc` attribute automatically discovering `.swcrc`:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(
    name = "compile",
    srcs = ["file.ts"],
)
```

Rules
=====


## swc_compile

Underlying rule for the `swc` macro.

Most users should use [swc](#swc) instead, as it predicts the output files
and has convenient default values.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### srcs

Required <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.




source files, typically .ts files in the source tree


### args

Optional list of strings.
Default: `[]`



Additional arguments to pass to swcx cli (NOT swc!).

NB: this is not the same as the CLI arguments for @swc/cli npm package.
For performance, rules_swc does not call a Node.js program wrapping the swc rust binding.
Instead, we directly spawn the (somewhat experimental) native Rust binary shipped inside the
@swc/core npm package, which the swc project calls "swcx"
Tracking issue for feature parity: https://github.com/swc-project/swc/issues/4017


### source_maps

Optional string.
Default: `"false"`



Create source map files for emitted JavaScript files.

see https://swc.rs/docs/usage/cli#--source-maps--s


### source_root

Optional string.
Default: `""`



Specify the root path for debuggers to find the reference source code.

see https://swc.rs/docs/usage/cli#--source-root

If not set, then the directory containing the source file is used.


### output_dir

Optional boolean.
Default: `False`



Whether to produce a directory output rather than individual files.

If out_dir is also specified, it is used as the name of the output directory.
Otherwise, the directory is named the same as the target.


### data

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Runtime dependencies to include in binaries/tests that depend on this target.

Follows the same semantics as `js_library` `data` attribute. See
https://docs.aspect.build/rulesets/aspect_rules_js/docs/js_library#data for more info.


### swcrc

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc


### plugins

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`

[Must provide `DefaultInfo,SwcPluginConfigInfo`] 

swc compilation plugins, created with swc_plugin rule


### out_dir

Optional string.
Default: `""`



With output_dir=False, output files will have this directory prefix.

With output_dir=True, this is the name of the output directory.


### root_dir

Optional string.
Default: `""`



a subdirectory under the input package which should be consider the root directory of all the input files


### emit_isolated_dts

Optional boolean.
Default: `False`



Emit .d.ts files instead of .js for TypeScript sources

EXPERIMENTAL: this API is undocumented, experimental and may change without notice


### default_ext

Optional string.
Default: `""`



Default extension for output files.

If a source file does not indicate a specific module type, this extension is used.

If unset, extensions will be determined based on the `js_outs` outputs attribute
or source file extensions.


### allow_js

Optional boolean.
Default: `True`



Allow JavaScript sources to be transpiled.

If False, only TypeScript sources will be transpiled.


### js_outs

Optional list of labels.
Default: `[]`



list of expected JavaScript output files.

There should be one for each entry in srcs.


### map_outs

Optional list of labels.
Default: `[]`



list of expected source map output files.

Can be empty, meaning no source maps should be produced.
If non-empty, there should be one for each entry in srcs.


### dts_outs

Optional list of labels.
Default: `[]`



list of expected TypeScript declaration files.

Can be empty, meaning no dts files should be produced.
If non-empty, there should be one for each entry in srcs.




# Macros and Functions


## swc

Execute the SWC compiler

 

### name

Required. 

A name for this target





### srcs

Required. 

List of labels of TypeScript source files.





### args

Optional. Default: `[]`

Additional options to pass to `swcx` cli, see https://github.com/swc-project/swc/discussions/3859
Note: we do **not** run the [NodeJS wrapper `@swc/cli`](https://swc.rs/docs/usage/cli)





### data

Optional. Default: `[]`

Files needed at runtime by binaries or tests that transitively depend on this target.
See https://bazel.build/reference/be/common-definitions#typical-attributes





### plugins

Optional. Default: `[]`

List of plugin labels created with `swc_plugin`.





### output_dir

Optional. Default: `False`

Whether to produce a directory output rather than individual files.

If `out_dir` is set, then that is used as the name of the output directory.
Otherwise, the output directory is named the same as the target.





### swcrc

Optional. Default: `None`

Label of a .swcrc configuration file for the SWC cli, see https://swc.rs/docs/configuration/swcrc
Instead of a label, you can pass a dictionary matching the JSON schema.
If this attribute isn't specified, and a file `.swcrc` exists in the same folder as this rule, it is used.

Note that some settings in `.swcrc` also appear in `tsconfig.json`.
See the notes in [/docs/tsconfig.md].





### source_maps

Optional. Default: `False`

If set, the --source-maps argument is passed to the SWC cli with the value.
See https://swc.rs/docs/usage/cli#--source-maps--s.
True/False are automaticaly converted to "true"/"false" string values the cli expects.





### out_dir

Optional. Default: `None`

The base directory for output files relative to the output directory for this package.

If output_dir is True, then this is used as the name of the output directory.





### root_dir

Optional. Default: `None`

A subdirectory under the input package which should be considered the root directory of all the input files





### default_ext

Optional. Default: `".js"`

The default extension to use for output files. If not set, the default is ".js".





### allow_js

Optional. Default: `True`

If `True` (default), then .js/.mjs/.cjs input files are transpiled. If `False`,
they are ignored. This can be used to mimic the behavior of tsc when using `ts_project(transpiler)`.





### kwargs

Optional. 

additional keyword arguments passed through to underlying [`swc_compile`](#swc_compile), eg. `visibility`, `tags`





## swc_plugin

Configure an SWC plugin

 

### name

Required. 

A name for this target





### srcs

Optional. Default: `[]`

Plugin files. Either a directory containing a package.json pointing at a wasm file
as the main entrypoint, or a wasm file. Usually a linked npm package target via rules_js.





### config

Optional. Default: `{}`

Optional configuration dict for the plugin. This is passed as a JSON object into the
`jsc.experimental.plugins` entry for the plugin.





### kwargs

Optional. 

additional keyword arguments passed through to underlying rule, eg. `visibility`, `tags`







