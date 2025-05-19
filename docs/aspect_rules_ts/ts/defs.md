<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

# Public API for TypeScript rules

The most commonly used is the [ts_project](#ts_project) macro which accepts TypeScript sources as
inputs and produces JavaScript or declaration (.d.ts) outputs.

Rules
=====


## ts_config

Allows a tsconfig.json file to extend another file.

Normally, you just give a single `tsconfig.json` file as the tsconfig attribute
of a `ts_library` or `ts_project` rule. However, if your `tsconfig.json` uses the `extends`
feature from TypeScript, then the Bazel implementation needs to know about that
extended configuration file as well, to pass them both to the TypeScript compiler.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### deps

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Additional tsconfig.json files referenced via extends


### src

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




The tsconfig.json file passed to the TypeScript compiler


## ts_project_rule

Implementation rule behind the ts_project macro.
Most users should use [ts_project](#ts_project) instead.

This skips conveniences like validation of the tsconfig attributes, default settings
for srcs and tsconfig, and pre-declaring output files.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### allow_js

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#allowJs


### composite

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#composite


### declaration

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#declaration


### declaration_map

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#declarationMap


### no_emit

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#noEmit


### emit_declaration_only

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#emitDeclarationOnly


### extends

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



https://www.typescriptlang.org/tsconfig#extends


### incremental

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#incremental


### preserve_jsx

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#jsx


### resolve_json_module

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#resolveJsonModule


### source_map

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig#sourceMap


### ts_build_info_file

Optional string.
Default: `""`



https://www.typescriptlang.org/tsconfig#tsBuildInfoFile


### generate_trace

Optional boolean.
Default: `False`



https://www.typescriptlang.org/tsconfig/#generateTrace


### assets

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Files which are needed by a downstream build step such as a bundler.

See more details on the `assets` parameter of the `ts_project` macro.


### args

Optional list of strings.
Default: `[]`



https://www.typescriptlang.org/docs/handbook/compiler-options.html


### data

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Runtime dependencies to include in binaries/tests that depend on this target.

Follows the same semantics as `js_library` `data` attribute. See
https://docs.aspect.build/rulesets/aspect_rules_js/docs/js_library#data for more info.


### declaration_dir

Optional string.
Default: `""`



https://www.typescriptlang.org/tsconfig#declarationDir


### deps

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



List of targets that produce TypeScript typings (`.d.ts` files)

Follows the same runfiles semantics as `js_library` `deps` attribute. See
https://docs.aspect.build/rulesets/aspect_rules_js/docs/js_library#deps for more info.


### out_dir

Optional string.
Default: `""`



https://www.typescriptlang.org/tsconfig#outDir


### root_dir

Optional string.
Default: `""`



https://www.typescriptlang.org/tsconfig#rootDir


### srcs

Required <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.




TypeScript source files


### supports_workers

Optional integer.
Default: `0`



Whether to use a custom `tsc` compiler which understands Bazel's persistent worker protocol.

See the docs for `supports_workers` on the [`ts_project`](#ts_project-supports_workers) macro.


### is_typescript_5_or_greater

Optional boolean.
Default: `False`



Whether TypeScript version is >= 5.0.0


### transpile

Optional integer.
Default: `-1`



Whether tsc should be used to produce .js outputs

Values are:
- -1: Error if --@aspect_rules_ts//ts:default_to_tsc_transpiler not set, otherwise transpile
- 0: Do not transpile
- 1: Transpile


### pretranspiled_js

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Externally transpiled .js to be included in output providers


### pretranspiled_dts

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Externally transpiled .d.ts to be included in output providers


### declaration_transpile

Optional boolean.
Default: `False`



Whether tsc should be used to produce .d.ts outputs


### tsc

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




TypeScript compiler binary


### tsc_worker

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




TypeScript compiler worker binary


### tsconfig

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




tsconfig.json file, see https://www.typescriptlang.org/tsconfig


### isolated_typecheck

Optional boolean.
Default: `False`



Whether type-checking should be a separate action.

This allows the transpilation action to run without waiting for typings from dependencies.

Requires a minimum version of typescript 5.6 for the [noCheck](https://www.typescriptlang.org/tsconfig#noCheck)
flag which is automatically set on the transpilation action when the typecheck action is isolated.

Requires [isolatedDeclarations](https://www.typescriptlang.org/tsconfig#isolatedDeclarations)
to be set so that declarations can be emitted without dependencies. The use of `isolatedDeclarations` may
require significant changes to your codebase and should be done as a pre-requisite to enabling `isolated_typecheck`.


### validate

Optional boolean.
Default: `True`



whether to add a Validation Action to verify the other attributes match
settings in the tsconfig.json file


### build_progress_message

Optional string.
Default: `"Transpiling{emit_part}{type_check_part} TypeScript project {label} [tsc -p {tsconfig_path}]"`



Custom progress message for the build action.
You can use {label} and {tsconfig_path} as substitutions.


### isolated_typecheck_progress_message

Optional string.
Default: `"Type-checking TypeScript project {label} [tsc -p {tsconfig_path}]"`



Custom progress message for the isolated typecheck action.
You can use {label} and {tsconfig_path} as substitutions.


### validator

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.







### buildinfo_out

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Location in bazel-out where tsc will write a `.tsbuildinfo` file


### js_outs

Optional list of labels.
Default: `[]`



Locations in bazel-out where tsc will write `.js` files


### map_outs

Optional list of labels.
Default: `[]`



Locations in bazel-out where tsc will write `.js.map` files


### typing_maps_outs

Optional list of labels.
Default: `[]`



Locations in bazel-out where tsc will write `.d.ts.map` files


### typings_outs

Optional list of labels.
Default: `[]`



Locations in bazel-out where tsc will write `.d.ts` files


### resource_set

Optional string.
Default: `"default"`



A predefined function used as the resource_set for actions.

Used with --experimental_action_resource_set to reserve more RAM/CPU, preventing Bazel overscheduling resource-intensive actions.

By default, Bazel allocates 1 CPU and 250M of RAM.
https://github.com/bazelbuild/bazel/blob/058f943037e21710837eda9ca2f85b5f8538c8c5/src/main/java/com/google/devtools/build/lib/actions/AbstractAction.java#L77




# Macros and Functions


## ts_project

Compiles one TypeScript project using `tsc --project`.

This is a drop-in replacement for the `tsc` rule automatically generated for the "typescript"
package, typically loaded from `@npm//typescript:package_json.bzl`.
Unlike bare `tsc`, this rule understands the Bazel interop mechanism (Providers)
so that this rule works with others that produce or consume TypeScript typings (`.d.ts` files).

One of the benefits of using ts_project is that it understands the [Bazel Worker Protocol]
which makes the overhead of starting the compiler be a one-time cost.
Worker mode is on by default to speed up build and typechecking process.

Some TypeScript options affect which files are emitted, and Bazel needs to predict these ahead-of-time.
As a result, several options from the tsconfig file must be mirrored as attributes to ts_project.
A validation action is run to help ensure that these are correctly mirrored.
See https://www.typescriptlang.org/tsconfig for a listing of the TypeScript options.

If you have problems getting your `ts_project` to work correctly, read the dedicated
[troubleshooting guide](/docs/troubleshooting.md).

[Bazel Worker Protocol]: https://bazel.build/remote/persistent


 

### name

Required. 

a name for this target





### tsconfig

Optional. Default: `None`

Label of the tsconfig.json file to use for the compilation.
To support "chaining" of more than one extended config, this label could be a target that
provides `TsConfigInfo` such as `ts_config`.

By default, if a "tsconfig.json" file is in the same folder with the ts_project rule, it is used.

Instead of a label, you can pass a dictionary matching the JSON schema.

See [docs/tsconfig.md](/docs/tsconfig.md) for detailed information.





### srcs

Optional. Default: `None`

List of labels of TypeScript source files to be provided to the compiler.

If absent, the default is set as follows:

- Include all TypeScript files in the package, recursively.
- If `allow_js` is set, include all JavaScript files in the package as well.
- If `resolve_json_module` is set, include all JSON files in the package,
  but exclude `package.json`, `package-lock.json`, and `tsconfig*.json`.





### args

Optional. Default: `[]`

List of strings of additional command-line arguments to pass to tsc.
See https://www.typescriptlang.org/docs/handbook/compiler-options.html#compiler-options
Typically useful arguments for debugging are `--listFiles` and `--listEmittedFiles`.





### data

Optional. Default: `[]`

Files needed at runtime by binaries or tests that transitively depend on this target.
See https://bazel.build/reference/be/common-definitions#typical-attributes





### deps

Optional. Default: `[]`

List of targets that produce TypeScript typings (`.d.ts` files)

If this list contains linked npm packages, npm package store targets or other targets that provide
`JsInfo`, `NpmPackageStoreInfo` providers are gathered from `JsInfo`. This is done directly from
the `npm_package_store_deps` field of these. For linked npm package targets, the underlying
`npm_package_store` target(s) that back the links is used. Gathered `NpmPackageStoreInfo`
providers are propagated to the direct dependencies of downstream linked `npm_package` targets.

NB: Linked npm package targets that are "dev" dependencies do not forward their underlying
`npm_package_store` target(s) through `npm_package_store_deps` and will therefore not be
propagated to the direct dependencies of downstream linked `npm_package` targets. npm packages
that come in from `npm_translate_lock` are considered "dev" dependencies if they are have
`dev: true` set in the pnpm lock file. This should be all packages that are only listed as
"devDependencies" in all `package.json` files within the pnpm workspace. This behavior is
intentional to mimic how `devDependencies` work in published npm packages.





### assets

Optional. Default: `[]`

Files which are needed by a downstream build step such as a bundler.

These files are **not** included as inputs to any actions spawned by `ts_project`.
They are not transpiled, and are not visible to the type-checker.
Instead, these files appear among the *outputs* of this target.

A typical use is when your TypeScript code has an import that TS itself doesn't understand
such as

`import './my.scss'`

and the type-checker allows this because you have an "ambient" global type declaration like

`declare module '*.scss' { ... }`

A bundler like webpack will expect to be able to resolve the `./my.scss` import to a file
and doesn't care about the typing declaration. A bundler runs as a build step,
so it does not see files included in the `data` attribute.

Note that `data` is used for files that are resolved by some binary, including a test
target. Behind the scenes, `data` populates Bazel's Runfiles object in `DefaultInfo`,
while this attribute populates the `transitive_sources` of the `JsInfo`.





### extends

Optional. Default: `None`

Label of the tsconfig file referenced in the `extends` section of tsconfig
To support "chaining" of more than one extended config, this label could be a target that
provdes `TsConfigInfo` such as `ts_config`.





### allow_js

Optional. Default: `False`

Whether TypeScript will read .js and .jsx files.
When used with `declaration`, TypeScript will generate `.d.ts` files from `.js` files.





### isolated_typecheck

Optional. Default: `False`

Whether to type-check asynchronously as a separate bazel action.
Requires https://devblogs.microsoft.com/typescript/announcing-typescript-5-6/#the---nocheck-option6
Requires https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html#isolated-declarations





### declaration

Optional. Default: `False`

Whether the `declaration` bit is set in the tsconfig.
Instructs Bazel to expect a `.d.ts` output for each `.ts` source.





### source_map

Optional. Default: `False`

Whether the `sourceMap` bit is set in the tsconfig.
Instructs Bazel to expect a `.js.map` output for each `.ts` source.





### declaration_map

Optional. Default: `False`

Whether the `declarationMap` bit is set in the tsconfig.
Instructs Bazel to expect a `.d.ts.map` output for each `.ts` source.





### resolve_json_module

Optional. Default: `None`

Boolean; specifies whether TypeScript will read .json files.
If set to True or False and tsconfig is a dict, resolveJsonModule is set in the generated config file.
If set to None and tsconfig is a dict, resolveJsonModule is unset in the generated config and typescript
default or extended tsconfig value will be load bearing.





### preserve_jsx

Optional. Default: `False`

Whether the `jsx` value is set to "preserve" in the tsconfig.
Instructs Bazel to expect a `.jsx` or `.jsx.map` output for each `.tsx` source.





### composite

Optional. Default: `False`

Whether the `composite` bit is set in the tsconfig.
Instructs Bazel to expect a `.tsbuildinfo` output and a `.d.ts` output for each `.ts` source.





### incremental

Optional. Default: `False`

Whether the `incremental` bit is set in the tsconfig.
Instructs Bazel to expect a `.tsbuildinfo` output.





### no_emit

Optional. Default: `False`

Whether the `noEmit` bit is set in the tsconfig.
Instructs Bazel *not* to expect any outputs.





### emit_declaration_only

Optional. Default: `False`

Whether the `emitDeclarationOnly` bit is set in the tsconfig.
Instructs Bazel *not* to expect `.js` or `.js.map` outputs for `.ts` sources.





### transpiler

Optional. Default: `None`

A custom transpiler tool to run that produces the JavaScript outputs instead of `tsc`.

Under `--@aspect_rules_ts//ts:default_to_tsc_transpiler`, the default is to use `tsc` to produce
`.js` outputs in the same action that does the type-checking to produce `.d.ts` outputs.
This is the simplest configuration, however `tsc` is slower than alternatives.
It also means developers must wait for the type-checking in the developer loop.

Without `--@aspect_rules_ts//ts:default_to_tsc_transpiler`, an explicit value must be set.
This may be the string `"tsc"` to explicitly choose `tsc`, just like the default above.

It may also be any rule or macro with this signature: `(name, srcs, **kwargs)`

If JavaScript outputs are configured to not be emitted the custom transpiler will not be used, such as
when `no_emit = True` or `emit_declaration_only = True`.

See [docs/transpiler.md](/docs/transpiler.md) for more details.





### declaration_transpiler

Optional. Default: `None`

A custom transpiler tool to run that produces the TypeScript declaration outputs instead of `tsc`.

It may be any rule or macro with this signature: `(name, srcs, **kwargs)`

If TypeScript declaration outputs are configured to not be emitted the custom declaration transpiler will
not be used, such as when `no_emit = True` or `declaration = False`.

See [docs/transpiler.md](/docs/transpiler.md) for more details.





### ts_build_info_file

Optional. Default: `None`

The user-specified value of `tsBuildInfoFile` from the tsconfig.
Helps Bazel to predict the path where the .tsbuildinfo output is written.





### generate_trace

Optional. Default: `None`

Whether to generate a trace file for TypeScript compiler performance analysis.
When enabled, creates a trace directory containing performance tracing information that can be
loaded in chrome://tracing. Use the `--@aspect_rules_ts//ts:generate_tsc_trace` flag to enable this by default.





### tsc

Optional. Default: `"@npm_typescript//:tsc"`

Label of the TypeScript compiler binary to run.
This allows you to use a custom API-compatible compiler in place of the regular `tsc` such as a custom `js_binary` or Angular's `ngc`.
compatible with it such as Angular's `ngc`.

See examples of use in [examples/custom_compiler](https://github.com/aspect-build/rules_ts/blob/main/examples/custom_compiler/BUILD.bazel)





### tsc_worker

Optional. Default: `"@npm_typescript//:tsc_worker"`

Label of a custom TypeScript compiler binary which understands Bazel's persistent worker protocol.





### validate

Optional. Default: `True`

Whether to check that the dependencies are valid and the tsconfig JSON settings match the attributes on this target.
Set this to `False` to skip running our validator, in case you have a legitimate reason for these to differ,
e.g. you have a setting enabled just for the editor but you want different behavior when Bazel runs `tsc`.





### validator

Optional. Default: `"@npm_typescript//:validator"`

Label of the tsconfig validator to run when `validate = True`.





### declaration_dir

Optional. Default: `None`

String specifying a subdirectory under the bazel-out folder where generated declaration
outputs are written. Equivalent to the TypeScript --declarationDir option.
By default declarations are written to the out_dir.





### out_dir

Optional. Default: `None`

String specifying a subdirectory under the bazel-out folder where outputs are written.
Equivalent to the TypeScript --outDir option.

Note that Bazel always requires outputs be written under a subdirectory matching the input package,
so if your rule appears in `path/to/my/package/BUILD.bazel` and out_dir = "foo" then the .js files
will appear in `bazel-out/[arch]/bin/path/to/my/package/foo/*.js`.

By default the out_dir is the package's folder under bazel-out.





### root_dir

Optional. Default: `None`

String specifying a subdirectory under the input package which should be consider the
root directory of all the input files.
Equivalent to the TypeScript --rootDir option.
By default it is '.', meaning the source directory where the BUILD file lives.





### supports_workers

Optional. Default: `-1`

Whether the "Persistent Worker" protocol is enabled.
This uses a custom `tsc` compiler to make rebuilds faster.
Note that this causes some known correctness bugs, see
https://docs.aspect.build/rules/aspect_rules_ts/docs/troubleshooting.
We do not intend to fix these bugs.

Worker mode can be enabled for all `ts_project`s in a build with the global
`--@aspect_rules_ts//ts:supports_workers` flag.
To enable worker mode for all builds in the workspace, add
`build --@aspect_rules_ts//ts:supports_workers` to the .bazelrc.

This is a "tri-state" attribute, accepting values `[-1, 0, 1]`. The behavior is:

- `-1`: use the value of the global `--@aspect_rules_ts//ts:supports_workers` flag.
- `0`: Override the global flag, disabling workers for this target.
- `1`: Override the global flag, enabling workers for this target.





### kwargs

Optional. 

passed through to underlying [`ts_project_rule`](#ts_project_rule), eg. `visibility`, `tags`





Providers
=========


## TsConfigInfo

Provides TypeScript configuration, in the form of a tsconfig.json file
along with any transitively referenced tsconfig.json files chained by the
"extends" feature



