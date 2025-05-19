<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

Rules for running JavaScript programs

Rules
=====


## js_info_files

Gathers files from the JsInfo providers from targets in srcs and provides them as default outputs.

This helper rule is used by the `js_run_binary` macro.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### srcs

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



List of targets to gather files from.


### include_sources

Optional boolean.
Default: `True`



When True, `sources` from `JsInfo` providers in `srcs` targets are included in the default outputs of the target.


### include_transitive_sources

Optional boolean.
Default: `True`



When True, `transitive_sources` from `JsInfo` providers in `srcs` targets are included in the default outputs of the target.


### include_types

Optional boolean.
Default: `False`



When True, `types` from `JsInfo` providers in `srcs` targets are included in the default outputs of the target.

Defaults to False since types are generally not needed at runtime and introducing them could slow down developer round trip
time due to having to generate typings on source file changes.

NB: These are types from direct `srcs` dependencies only. You may also need to set `include_transitive_types` to True.


### include_transitive_types

Optional boolean.
Default: `False`



When True, `transitive_types` from `JsInfo` providers in `srcs` targets are included in the default outputs of the target.

Defaults to False since types are generally not needed at runtime and introducing them could slow down developer round trip
time due to having to generate typings on source file changes.


### include_npm_sources

Optional boolean.
Default: `True`



When True, files in `npm_sources` from `JsInfo` providers in `srcs` targets are included in the default outputs of the target.

`transitive_files` from `NpmPackageStoreInfo` providers in `srcs` targets are also included in the default outputs of the target.


## js_image_layer

Create container image layers from js_binary targets.

By design, js_image_layer doesn't have any preference over which rule assembles the container image.
This means the downstream rule (`oci_image` from [rules_oci](https://github.com/bazel-contrib/rules_oci)
or `container_image` from [rules_docker](https://github.com/bazelbuild/rules_docker)) must
set a proper `workdir` and `cmd` to for the container work.

A proper `cmd` usually looks like /`[ js_image_layer 'root' ]`/`[ package name of js_image_layer 'binary' target ]/[ name of js_image_layer 'binary' target ]`,
unless you have a custom launcher script that invokes the entry_point of the `js_binary` in a different path.

On the other hand, `workdir` has to be set to the "runfiles tree root" which would be exactly `cmd` **but with `.runfiles/[ name of the workspace ]` suffix**.
If using bzlmod then name of the local workspace is always `_main`. If bzlmod is not enabled then the name of the local workspace, if not otherwise specified
in the `WORKSPACE` file, is `__main__`. If `workdir` is not set correctly, some attributes such as `chdir` might not work properly.

js_image_layer creates up to 5 layers depending on what files are included in the runfiles of the provided
`binary` target.

1. `node` layer contains the Node.js toolchain
2. `package_store_3p` layer contains all 3p npm deps in the `node_modules/.aspect_rules_js` package store
3. `package_store_1p` layer contains all 1p npm deps in the `node_modules/.aspect_rules_js` package store
4. `node_modules` layer contains all `node_modules/*` symlinks which point into the package store
5. `app` layer contains all files that don't fall into any of the above layers

If no files are found in the runfiles of the `binary` target for one of the layers above, that
layer is not generated. All generated layer tarballs are provided as `DefaultInfo` files.

> The rules_js `node_modules/.aspect_rules_js` package store follows the same pattern as the pnpm
> `node_modules/.pnpm` virtual store. For more information see https://pnpm.io/symlinked-node-modules-structure.

js_image_layer also provides an `OutputGroupInfo` with outputs for each of the layers above which
can be used to reference an individual layer with using `filegroup` with `output_group`. For example,

```starlark
js_image_layer(
    name = "layers",
    binary = ":bin",
    root = "/app",
)

filegroup(
    name = "app_tar",
    srcs = [":layers"],
    output_group = "app",
)
```

> WARNING: The structure of the generated layers are not subject to semver guarantees and may change without a notice.
> However, it is guaranteed to work when all generated layers are provided together in the order specified above.

js_image_layer supports transitioning to specific `platform` to allow building multi-platform container images.

**A partial example using rules_oci with transition to linux/amd64 platform.**

```starlark
load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_image_layer")
load("@rules_oci//oci:defs.bzl", "oci_image")

js_binary(
    name = "bin",
    entry_point = "main.js",
)

platform(
    name = "amd64_linux",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

js_image_layer(
    name = "layers",
    binary = ":bin",
    platform = ":amd64_linux",
    root = "/app",
)

oci_image(
    name = "image",
    cmd = ["/app/bin"],
    entrypoint = ["bash"],
    tars = [
        ":layers"
    ],
    workdir = select({
        "@aspect_bazel_lib//lib:bzlmod": "/app/bin.runfiles/_main",
        "//conditions:default": "/app/bin.runfiles/__main__",
    }),
)
```

**A partial example using rules_oci to create multi-platform images.**

```starlark
load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_image_layer")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_image_index")

js_binary(
    name = "bin",
    entry_point = "main.js",
)

[
    platform(
        name = "linux_{}".format(arch),
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:{}".format(arch if arch != "amd64" else "x86_64"),
        ],
    )

    js_image_layer(
        name = "{}_layers".format(arch),
        binary = ":bin",
        platform = ":linux_{arch}",
        root = "/app",
    )

    oci_image(
        name = "{}_image".format(arch),
        cmd = ["/app/bin"],
        entrypoint = ["bash"],
        tars = [
            ":{}_layers".format(arch)
        ],
        workdir = select({
            "@aspect_bazel_lib//lib:bzlmod": "/app/bin.runfiles/_main",
            "//conditions:default": "/app/bin.runfiles/__main__",
        }),
    )

    for arch in ["amd64", "arm64"]
]

oci_image_index(
    name = "image",
    images = [
        ":arm64_image",
        ":amd64_image"
    ]
)
```

**An example using legacy rules_docker**

See `e2e/js_image_docker` for full example.

```starlark
load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_image_layer")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")

js_binary(
    name = "bin",
    data = [
        "//:node_modules/args-parser",
    ],
    entry_point = "main.js",
)

js_image_layer(
    name = "layers",
    binary = ":bin",
    root = "/app",
    visibility = ["//visibility:__pkg__"],
)

filegroup(
    name = "node_tar",
    srcs = [":layers"],
    output_group = "node",
)

container_layer(
    name = "node_layer",
    tars = [":node_tar"],
)

filegroup(
    name = "package_store_3p_tar",
    srcs = [":layers"],
    output_group = "package_store_3p",
)

container_layer(
    name = "package_store_3p_layer",
    tars = [":package_store_3p_tar"],
)

filegroup(
    name = "package_store_1p_tar",
    srcs = [":layers"],
    output_group = "package_store_1p",
)

container_layer(
    name = "package_store_1p_layer",
    tars = [":package_store_1p_tar"],
)

filegroup(
    name = "node_modules_tar",
    srcs = [":layers"],
    output_group = "node_modules",
)

container_layer(
    name = "node_modules_layer",
    tars = [":node_modules_tar"],
)

filegroup(
    name = "app_tar",
    srcs = [":layers"],
    output_group = "app",
)

container_layer(
    name = "app_layer",
    tars = [":app_tar"],
)

container_image(
    name = "image",
    cmd = ["/app/bin"],
    entrypoint = ["bash"],
    layers = [
        ":node_layer",
        ":package_store_3p_layer",
        ":package_store_1p_layer",
        ":node_modules_layer",
        ":app_layer",
    ],
    workdir = select({
        "@aspect_bazel_lib//lib:bzlmod": "/app/bin.runfiles/_main",
        "//conditions:default": "/app/bin.runfiles/__main__",
    }),
)
```


## Performance

For better performance, it is recommended to split the large parts of a `js_binary` to have a separate layer.

The matching order for layer groups is as follows:

1. `layer_groups` are checked in order first
2. If no match is found for `layer_groups`, the `default layer groups` are checked.
3. Any remaining files are placed into the app layer.

The default layer groups are as follows and always created.

```
{
    "node": "/js/private/node-patches/|/bin/nodejs/",
    "package_store_1p": "\.aspect_rules_js/.*@0\.0\.0/node_modules",
    "package_store_3p": "\.aspect_rules_js/.*/node_modules",
    "node_modules": "/node_modules/",
    "app": "", # empty means just match anything.
}
```


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### binary

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




Label to an js_binary target


### root

Optional string.
Default: `""`



Path where the files from js_binary will reside in. eg: /apps/app1 or /app


### owner

Optional string.
Default: `"0:0"`



Owner of the entries, in `GID:UID` format. By default `0:0` (root, root) is used.


### compression

Optional string.
Default: `"gzip"`



Compression algorithm. See https://github.com/bazel-contrib/bazel-lib/blob/bdc6ade0ba1ebe88d822bcdf4d4aaa2ce7e2cd37/lib/private/tar.bzl#L29-L39


### platform

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Platform to transition.


### generate_empty_layers

Optional boolean.
Default: `False`



DEPRECATED. An empty layer is always generated if the layer group have no matching files.


### preserve_symlinks

Optional string.
Default: `".*/node_modules/.*"`



Preserve symlinks for entries matching the pattern.
By default symlinks within the `node_modules` is preserved.


### layer_groups

Optional <a href="https://bazel.build/docs/skylark/lib/dict.html">dictionary: String → String</a>.
Default: `{}`



Layer groups to create.
These are utilized to categorize files into distinct layers, determined by their respective paths.
The expected format for each entry is "<key>": "<value>", where <key> MUST be a valid Bazel and
JavaScript identifier (alphanumeric characters), and <value> MAY be either an empty string (signifying a universal match)
or a valid regular expression.




# Macros and Functions


## js_binary



 

### kwargs

Optional. 







## js_test



 

### kwargs

Optional. 







## js_library



 

### kwargs

Optional. 







## js_run_devserver

Runs a devserver via binary target or command.

A simple http-server, for example, can be setup as follows,

```
load("@aspect_rules_js//js:defs.bzl", "js_run_devserver")
load("@npm//:http-server/package_json.bzl", http_server_bin = "bin")

http_server_bin.http_server_binary(
    name = "http_server",
)

js_run_devserver(
    name = "serve",
    args = ["."],
    data = ["index.html"],
    tool = ":http_server",
)
```

A Next.js devserver can be setup as follows,

```
js_run_devserver(
    name = "dev",
    args = ["dev"],
    command = "./node_modules/.bin/next",
    data = [
        "next.config.js",
        "package.json",
        ":node_modules/next",
        ":node_modules/react",
        ":node_modules/react-dom",
        ":node_modules/typescript",
        "//pages",
        "//public",
        "//styles",
    ],
)
```

where the `./node_modules/.bin/next` bin entry of Next.js is configured in
`npm_translate_lock` as such,

```
npm_translate_lock(
    name = "npm",
    bins = {
        # derived from "bin" attribute in node_modules/next/package.json
        "next": {
            "next": "./dist/bin/next",
        },
    },
    pnpm_lock = "//:pnpm-lock.yaml",
)
```

and run in watch mode using [ibazel](https://github.com/bazelbuild/bazel-watcher) with
`ibazel run //:dev`.

The devserver specified by either `tool` or `command` is run in a custom sandbox that is more
compatible with devserver watch modes in Node.js tools such as Webpack and Next.js.

The custom sandbox is populated with the default outputs of all targets in `data`
as well as transitive sources & npm links.

As an optimization, package store files are explicitly excluded from the sandbox since the npm
links will point to the package store in the execroot and Node.js will follow those links as it
does within the execroot. As a result, rules_js npm package link targets such as
`//:node_modules/next` are handled efficiently. Since these targets are symlinks in the output
tree, they are recreated as symlinks in the custom sandbox and do not incur a full copy of the
underlying npm packages.

Supports running with [ibazel](https://github.com/bazelbuild/bazel-watcher).
Only `data` files that change on incremental builds are synchronized when running with ibazel.

Note that the use of `alias` targets is not supported by ibazel: https://github.com/bazelbuild/bazel-watcher/issues/100




### name

Required. 

A unique name for this target.





### tool

Optional. Default: `None`

The devserver binary target to run.

Only one of `command` or `tool` may be specified.





### command

Optional. Default: `None`

The devserver command to run.

For example, this could be the bin entry of an npm package that is included
in data such as `./node_modules/.bin/next`.

Using the bin entry of next, for example, resolves issues with Next.js and React
being found in multiple node_modules trees when next is run as an encapsulated
`js_binary` tool.

Only one of `command` or `tool` may be specified.





### grant_sandbox_write_permissions

Optional. Default: `False`

If set, write permissions is set on all files copied to the custom sandbox.

This can be useful to support some devservers such as Next.js which may, under some
circumstances, try to modify files when running.

See https://github.com/aspect-build/rules_js/issues/935 for more context.





### use_execroot_entry_point

Optional. Default: `True`

Use the `entry_point` script of the `js_binary` `tool` that is in the execroot output tree
instead of the copy that is in runfiles.

Using the entry point script that is in the execroot output tree means that there will be no conflicting
runfiles `node_modules` in the node_modules resolution path which can confuse npm packages such as next and
react that don't like being resolved in multiple node_modules trees. This more closely emulates the
environment that tools such as Next.js see when they are run outside of Bazel.

When True, the `js_binary` tool must have `copy_data_to_bin` set to True (the default) so that all data files
needed by the binary are available in the execroot output tree. This requirement can be turned off with by
setting `allow_execroot_entry_point_with_no_copy_data_to_bin` to True.





### allow_execroot_entry_point_with_no_copy_data_to_bin

Optional. Default: `False`

Turn off validation that the `js_binary` tool
has `copy_data_to_bin` set to True when `use_execroot_entry_point` is set to True.

See `use_execroot_entry_point` doc for more info.





### kwargs

Optional. 

All other args from `js_binary` except for `entry_point` which is set implicitly.

`entry_point` is set implicitly by `js_run_devserver` and cannot be overridden.

See https://docs.aspect.build/rules/aspect_rules_js/docs/js_binary





## js_run_binary

Wrapper around @aspect_bazel_lib `run_binary` that adds convenience attributes for using a `js_binary` tool.

This rule does not require Bash `native.genrule`.

The following environment variables are made available to the Node.js runtime based on available Bazel [Make variables](https://bazel.build/reference/be/make-variables#predefined_variables):

* BAZEL_BINDIR: the WORKSPACE-relative bazel bin directory; equivalent to the `$(BINDIR)` Make variable of the `js_run_binary` target
* BAZEL_COMPILATION_MODE: One of `fastbuild`, `dbg`, or `opt` as set by [`--compilation_mode`](https://bazel.build/docs/user-manual#compilation-mode); equivalent to `$(COMPILATION_MODE)` Make variable of the `js_run_binary` target
* BAZEL_TARGET_CPU: the target cpu architecture; equivalent to `$(TARGET_CPU)` Make variable of the `js_run_binary` target

The following environment variables are made available to the Node.js runtime based on the rule context:

* BAZEL_BUILD_FILE_PATH: the WORKSPACE-relative path to the BUILD file of the bazel target being run; equivalent to `ctx.build_file_path` of the `js_run_binary` target's rule context
* BAZEL_PACKAGE: the package of the bazel target being run; equivalent to `ctx.label.package` of the `js_run_binary` target's rule context
* BAZEL_TARGET_NAME: the full label of the bazel target being run; a stringified version of `ctx.label` of the `js_run_binary` target's rule context
* BAZEL_TARGET: the name of the bazel target being run; equivalent to `ctx.label.name` of the  `js_run_binary` target's rule context
* BAZEL_WORKSPACE: the bazel workspace name; equivalent to `ctx.workspace_name` of the `js_run_binary` target's rule context


 

### name

Required. 

Target name





### tool

Required. 

The tool to run in the action.

Should be a `js_binary` rule. Use Aspect bazel-lib's run_binary
(https://github.com/bazel-contrib/bazel-lib/blob/main/lib/run_binary.bzl)
for other *_binary rule types.





### env

Optional. Default: `{}`

Environment variables of the action.

Subject to `$(location)` and make variable expansion.





### srcs

Optional. Default: `[]`

Additional inputs of the action.

These labels are available for `$(location)` expansion in `args` and `env`.





### outs

Optional. Default: `[]`

Output files generated by the action.

These labels are available for `$(location)` expansion in `args` and `env`.





### out_dirs

Optional. Default: `[]`

Output directories generated by the action.

These labels are _not_ available for `$(location)` expansion in `args` and `env` since
they are not pre-declared labels created via attr.output_list(). Output directories are
declared instead by `ctx.actions.declare_directory`.





### args

Optional. Default: `[]`

Command line arguments of the binary.

Subject to `$(location)` and make variable expansion.





### chdir

Optional. Default: `None`

Working directory to run the build action in.

This overrides the chdir value if set on the `js_binary` tool target.

By default, `js_binary` tools run in the root of the output tree. For more context on why, please read the
aspect_rules_js README
https://github.com/aspect-build/rules_js/tree/dbb5af0d2a9a2bb50e4cf4a96dbc582b27567155#running-nodejs-programs.

To run in the directory containing the js_run_binary in the output tree, use
`chdir = package_name()` (or if you're in a macro, use `native.package_name()`).

WARNING: this will affect other paths passed to the program, either as arguments or in configuration files,
which are workspace-relative.

You may need `../../` segments to re-relativize such paths to the new working directory.





### stdout

Optional. Default: `None`

Output file to capture the stdout of the binary.

This can later be used as an input to another target subject to the same semantics as `outs`.

If the binary creates outputs and these are declared, they must still be created.





### stderr

Optional. Default: `None`

Output file to capture the stderr of the binary to.

This can later be used as an input to another target subject to the same semantics as `outs`.

If the binary creates outputs and these are declared, they must still be created.





### exit_code_out

Optional. Default: `None`

Output file to capture the exit code of the binary to.

This can later be used as an input to another target subject to the same semantics as `outs`. Note that
setting this will force the binary to exit 0.

If the binary creates outputs and these are declared, they must still be created.





### silent_on_success

Optional. Default: `True`

produce no output on stdout nor stderr when program exits with status code 0.

This makes node binaries match the expected bazel paradigm.





### use_execroot_entry_point

Optional. Default: `True`

Use the `entry_point` script of the `js_binary` `tool` that is in the execroot output tree
instead of the copy that is in runfiles.

Runfiles of `tool` are all hoisted to `srcs` of the underlying `run_binary` so they are included as execroot
inputs to the action.

Using the entry point script that is in the execroot output tree means that there will be no conflicting
runfiles `node_modules` in the node_modules resolution path which can confuse npm packages such as next and
react that don't like being resolved in multiple node_modules trees. This more closely emulates the
environment that tools such as Next.js see when they are run outside of Bazel.

When True, the `js_binary` tool must have `copy_data_to_bin` set to True (the default) so that all data files
needed by the binary are available in the execroot output tree. This requirement can be turned off with by
setting `allow_execroot_entry_point_with_no_copy_data_to_bin` to True.





### copy_srcs_to_bin

Optional. Default: `True`

When True, all srcs files are copied to the output tree that are not already there.





### include_sources

Optional. Default: `True`

see `js_info_files` documentation





### include_types

Optional. Default: `False`

see `js_info_files` documentation





### include_transitive_sources

Optional. Default: `True`

see `js_info_files` documentation





### include_transitive_types

Optional. Default: `False`

see `js_info_files` documentation





### include_npm_sources

Optional. Default: `True`

see `js_info_files` documentation





### log_level

Optional. Default: `None`

Set the logging level of the `js_binary` tool.

This overrides the log level set on the `js_binary` tool target.





### mnemonic

Optional. Default: `"JsRunBinary"`

A one-word description of the action, for example, CppCompile or GoLink.





### progress_message

Optional. Default: `None`

Progress message to show to the user during the build, for example,
"Compiling foo.cc to create foo.o". The message may contain %{label}, %{input}, or
%{output} patterns, which are substituted with label string, first input, or output's
path, respectively. Prefer to use patterns instead of static strings, because the former
are more efficient.





### execution_requirements

Optional. Default: `None`

Information for scheduling the action.

For example,

```
execution_requirements = {
    "no-cache": "1",
},
```

See https://docs.bazel.build/versions/main/be/common-definitions.html#common.tags for useful keys.





### stamp

Optional. Default: `0`

Whether to include build status files as inputs to the tool. Possible values:

- `stamp = 0 (default)`: Never include build status files as inputs to the tool.
    This gives good build result caching.
    Most tools don't use the status files, so including them in `--stamp` builds makes those
    builds have many needless cache misses.
    (Note: this default is different from most rules with an integer-typed `stamp` attribute.)
- `stamp = 1`: Always include build status files as inputs to the tool, even in
    [--nostamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) builds.
    This setting should be avoided, since it is non-deterministic.
    It potentially causes remote cache misses for the target and
    any downstream actions that depend on the result.
- `stamp = -1`: Inclusion of build status files as inputs is controlled by the
    [--[no]stamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) flag.
    Stamped targets are not rebuilt unless their dependencies change.

Default value is `0` since the majority of js_run_binary targets in a build graph typically do not use build
status files and including them for all js_run_binary actions whenever `--stamp` is set would result in
invalidating the entire graph and would prevent cache hits. Stamping is typically done in terminal targets
when building release artifacts and stamp should typically be set explicitly in these targets to `-1` so it
is enabled when the `--stamp` flag is set.

When stamping is enabled, an additional two environment variables will be set for the action:
    - `BAZEL_STABLE_STATUS_FILE`
    - `BAZEL_VOLATILE_STATUS_FILE`

These files can be read and parsed by the action, for example to pass some values to a bundler.





### patch_node_fs

Optional. Default: `True`

Patch the to Node.js `fs` API (https://nodejs.org/api/fs.html) for this node program
to prevent the program from following symlinks out of the execroot, runfiles and the sandbox.

When enabled, `js_binary` patches the Node.js sync and async `fs` API functions `lstat`,
`readlink`, `realpath`, `readdir` and `opendir` so that the node program being
run cannot resolve symlinks out of the execroot and the runfiles tree. When in the sandbox,
these patches prevent the program being run from resolving symlinks out of the sandbox.

When disabled, node programs can leave the execroot, runfiles and sandbox by following symlinks
which can lead to non-hermetic behavior.





### allow_execroot_entry_point_with_no_copy_data_to_bin

Optional. Default: `False`

Turn off validation that the `js_binary` tool
has `copy_data_to_bin` set to True when `use_execroot_entry_point` is set to True.

See `use_execroot_entry_point` doc for more info.





### use_default_shell_env

Optional. Default: `None`

If set, passed to the underlying run_binary.

May introduce non-determinism when True; use with care!
See e.g. https://github.com/bazelbuild/bazel/issues/4912

Requires a minimum of aspect_bazel_lib v1.40.3 or v2.4.2.

Refer to https://bazel.build/rules/lib/builtins/actions#run for more details.





### kwargs

Optional. 

Additional arguments







