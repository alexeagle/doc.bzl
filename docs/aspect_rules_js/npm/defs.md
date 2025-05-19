<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

Rules for fetching and linking npm dependencies and packaging and linking first-party deps



# Macros and Functions


## npm_package

A macro that packages sources into a directory (a tree artifact) and provides an `NpmPackageInfo`.

This target can be used as the `src` attribute to `npm_link_package`.

With `publishable = True` the macro also produces a target `[name].publish`, that can be run to publish to an npm registry.
Under the hood, this target runs `npm publish`. You can pass arguments to npm by escaping them from Bazel using a double-hyphen,
for example: `bazel run //path/to:my_package.publish -- --tag=next`

Files and directories can be arranged as needed in the output directory using
the `root_paths`, `include_srcs_patterns`, `exclude_srcs_patterns` and `replace_prefixes` attributes.

Filters and transformations are applied in the following order:

1. `include_external_repositories`

2. `include_srcs_packages`

3. `exclude_srcs_packages`

4. `root_paths`

5. `include_srcs_patterns`

6. `exclude_srcs_patterns`

7. `replace_prefixes`

For more information each filters / transformations applied, see
the documentation for the specific filter / transformation attribute.

Glob patterns are supported. Standard wildcards (globbing patterns) plus the `**` doublestar (aka. super-asterisk)
are supported with the underlying globbing library, https://github.com/bmatcuk/doublestar. This is the same
globbing library used by [gazelle](https://github.com/bazelbuild/bazel-gazelle). See https://github.com/bmatcuk/doublestar#patterns
for more information on supported globbing patterns.

`npm_package` makes use of `copy_to_directory`
(https://docs.aspect.build/rules/aspect_bazel_lib/docs/copy_to_directory) under the hood,
adopting its API and its copy action using composition. However, unlike `copy_to_directory`,
`npm_package` includes direct and transitive sources and types files from `JsInfo` providers in srcs
by default. The behavior of including sources and types from `JsInfo` can be configured
using the `include_sources`, `include_transitive_sources`, `include_types`, `include_transitive_types`.

The two `include*_types` options may cause type-check actions to run, which slows down your
development round-trip.

As of rules_js 2.0, the recommended solution for avoiding eager type-checking when linking
1p deps is to link `js_library` or any `JsInfo` producing targets directly without the
indirection of going through an `npm_package` target (see https://github.com/aspect-build/rules_js/pull/1646
for more details).

`npm_package` can also include npm packages sources and default runfiles from `srcs` which `copy_to_directory` does not.
These behaviors can be configured with the `include_npm_sourfes` and `include_runfiles` attributes
respectively.

The default `include_srcs_packages`, `[".", "./**"]`, prevents files from outside of the target's
package and subpackages from being included.

The default `exclude_srcs_patterns`, of `["node_modules/**", "**/node_modules/**"]`, prevents
`node_modules` files from being included.

To stamp the current git tag as the "version" in the package.json file, see
[stamped_package_json](#stamped_package_json)


 

### name

Required. 

Unique name for this target.





### srcs

Optional. Default: `[]`

Files and/or directories or targets that provide `DirectoryPathInfo` to copy into the output directory.





### data

Optional. Default: `[]`

Runtime / linktime npm dependencies of this npm package.

`NpmPackageStoreInfo` providers are gathered from `JsInfo` of the targets specified. Targets can be linked npm
packages, npm package store targets or other targets that provide `JsInfo`. This is done directly from the
`npm_package_store_infos` field of these. For linked npm package targets, the underlying npm_package_store
target(s) that back the links is used.

Gathered `NpmPackageStoreInfo` providers are used downstream as direct dependencies of this npm package when
linking with `npm_link_package`.





### args

Optional. Default: `[]`

Arguments that are passed down to `<name>.publish` target and `npm publish` command.





### out

Optional. Default: `None`

Path of the output directory, relative to this package.





### package

Optional. Default: `""`

The package name. If set, should match the `name` field in the `package.json` file for this package.

If set, the package name set here will be used for linking if a npm_link_package does not specify a package name. A
npm_link_package that specifies a package name will override the value here when linking.

If unset, a npm_link_package that references this npm_package must define the package name must be for linking.





### version

Optional. Default: `"0.0.0"`

The package version. If set, should match the `version` field in the `package.json` file for this package.

If set, a npm_link_package may omit the package version and the package version set here will be used for linking. A
npm_link_package that specifies a package version will override the value here when linking.

If unset, a npm_link_package that references this npm_package must define the package version must be for linking.





### root_paths

Optional. Default: `["."]`

List of paths (with glob support) that are roots in the output directory.

If any parent directory of a file being copied matches one of the root paths
patterns specified, the output directory path will be the path relative to the root path
instead of the path relative to the file's workspace. If there are multiple
root paths that match, the longest match wins.

Matching is done on the parent directory of the output file path so a trailing '**' glob patterm
will match only up to the last path segment of the dirname and will not include the basename.
Only complete path segments are matched. Partial matches on the last segment of the root path
are ignored.

Forward slashes (`/`) should be used as path separators.

A `"."` value expands to the target's package path (`ctx.label.package`).

Defaults to `["."]` which results in the output directory path of files in the
target's package and and sub-packages are relative to the target's package and
files outside of that retain their full workspace relative paths.

Globs are supported (see rule docstring above).





### include_external_repositories

Optional. Default: `[]`

List of external repository names (with glob support) to include in the output directory.

Files from external repositories are only copied into the output directory if
the external repository they come from matches one of the external repository patterns
specified.

When copied from an external repository, the file path in the output directory
defaults to the file's path within the external repository. The external repository
name is _not_ included in that path.

For example, the following copies `@external_repo//path/to:file` to
`path/to/file` within the output directory.

```
npp_package(
    name = "dir",
    include_external_repositories = ["external_*"],
    srcs = ["@external_repo//path/to:file"],
)
```

Files that come from matching external are subject to subsequent filters and
transformations to determine if they are copied and what their path in the output
directory will be. The external repository name of the file from an external
repository is not included in the output directory path and is considered in subsequent
filters and transformations.

Globs are supported (see rule docstring above).





### include_srcs_packages

Optional. Default: `["./**"]`

List of Bazel packages (with glob support) to include in output directory.

Files in srcs are only copied to the output directory if
the Bazel package of the file matches one of the patterns specified.

Forward slashes (`/`) should be used as path separators. A first character of `"."`
will be replaced by the target's package path.

Defaults to ["./**"] which includes sources target's package and subpackages.

Files that have matching Bazel packages are subject to subsequent filters and
transformations to determine if they are copied and what their path in the output
directory will be.

Globs are supported (see rule docstring above).





### exclude_srcs_packages

Optional. Default: `[]`

List of Bazel packages (with glob support) to exclude from output directory.

Files in srcs are not copied to the output directory if
the Bazel package of the file matches one of the patterns specified.

Forward slashes (`/`) should be used as path separators. A first character of `"."`
will be replaced by the target's package path.

Defaults to ["**/node_modules/**"] which excludes all node_modules folders
from the output directory.

Files that have do not have matching Bazel packages are subject to subsequent
filters and transformations to determine if they are copied and what their path in the output
directory will be.

Globs are supported (see rule docstring above).





### include_srcs_patterns

Optional. Default: `["**"]`

List of paths (with glob support) to include in output directory.

Files in srcs are only copied to the output directory if their output
directory path, after applying `root_paths`, matches one of the patterns specified.

Forward slashes (`/`) should be used as path separators.

Defaults to `["**"]` which includes all sources.

Files that have matching output directory paths are subject to subsequent
filters and transformations to determine if they are copied and what their path in the output
directory will be.

Globs are supported (see rule docstring above).





### exclude_srcs_patterns

Optional. Default: `["**/node_modules/**"]`

List of paths (with glob support) to exclude from output directory.

Files in srcs are not copied to the output directory if their output
directory path, after applying `root_paths`, matches one of the patterns specified.

Forward slashes (`/`) should be used as path separators.

Files that do not have matching output directory paths are subject to subsequent
filters and transformations to determine if they are copied and what their path in the output
directory will be.

Globs are supported (see rule docstring above).





### replace_prefixes

Optional. Default: `{}`

Map of paths prefixes (with glob support) to replace in the output directory path when copying files.

If the output directory path for a file starts with or fully matches a
a key in the dict then the matching portion of the output directory path is
replaced with the dict value for that key. The final path segment
matched can be a partial match of that segment and only the matching portion will
be replaced. If there are multiple keys that match, the longest match wins.

Forward slashes (`/`) should be used as path separators.

Replace prefix transformation are the final step in the list of filters and transformations.
The final output path of a file being copied into the output directory
is determined at this step.

Globs are supported (see rule docstring above).





### allow_overwrites

Optional. Default: `False`

If True, allow files to be overwritten if the same output file is copied to twice.

The order of srcs matters as the last copy of a particular file will win when overwriting.
Performance of `npm_package` will be slightly degraded when allow_overwrites is True
since copies cannot be parallelized out as they are calculated. Instead all copy paths
must be calculated before any copies can be started.





### include_sources

Optional. Default: `True`

When True, `sources` from `JsInfo` providers in `srcs` targets are included in the list of available files to copy.





### include_types

Optional. Default: `True`

When True, `types` from `JsInfo` providers in `srcs` targets are included in the list of available files to copy.





### include_transitive_sources

Optional. Default: `True`

When True, `transitive_sources` from `JsInfo` providers in `srcs` targets are included in the list of available files to copy.





### include_transitive_types

Optional. Default: `True`

When True, `transitive_types` from `JsInfo` providers in `srcs` targets are included in the list of available files to copy.





### include_npm_sources

Optional. Default: `False`

When True, `npm_sources` from `JsInfo` providers in `srcs` targets are included in the list of available files to copy.





### include_runfiles

Optional. Default: `False`

When True, default runfiles from `srcs` targets are included in the list of available files to copy.

This may be needed in a few cases:

- to work-around issues with rules that don't provide everything needed in sources, transitive_sources, types & transitive_types
- to depend on the runfiles targets that don't use JsInfo

NB: The default value will be flipped to False in the next major release as runfiles are not needed in the general case
and adding them to the list of files available to copy can add noticeable overhead to the analysis phase in a large
repository with many npm_package targets.





### hardlink

Optional. Default: `"auto"`

Controls when to use hardlinks to files instead of making copies.

Creating hardlinks is much faster than making copies of files with the caveat that
hardlinks share file permissions with their source.

Since Bazel removes write permissions on files in the output tree after an action completes,
hardlinks to source files are not recommended since write permissions will be inadvertently
removed from sources files.

- `auto`: hardlinks are used for generated files already in the output tree
- `off`: all files are copied
- `on`: hardlinks are used for all files (not recommended)





### publishable

Optional. Default: `False`

When True, enable generation of `{name}.publish` target





### verbose

Optional. Default: `False`

If true, prints out verbose logs to stdout





### kwargs

Optional. 

Additional attributes such as `tags` and `visibility`





## npm_link_package

"Links an npm package to node_modules if link is True.

When called at the root_package, a package store target is generated named `link__{bazelified_name}__store`.

When linking, a `{name}` target is generated which consists of the `node_modules/<package>` symlink and transitively
its package store link and the package store links of the transitive closure of deps.

When linking, `{name}/dir` filegroup is also generated that refers to a directory artifact can be used to access
the package directory for creating entry points or accessing files in the package.


 

### name

Required. 

The name of the link target to create if `link` is True.
For first-party deps linked across a workspace, the name must match in all packages
being linked as it is used to derive the package store link target name.





### root_package

Optional. Default: `""`

the root package where the node_modules package store is linked to





### link

Optional. Default: `True`

whether or not to link in this package
If false, only the npm_package_store target will be created _if_ this is called in the `root_package`.





### src

Optional. Default: `None`

the npm_package target to link; may only to be specified when linking in the root package





### deps

Optional. Default: `{}`

list of npm_package_store; may only to be specified when linking in the root package





### fail_if_no_link

Optional. Default: `True`

whether or not to fail if this is called in a package that is not the root package and `link` is False





### auto_manual

Optional. Default: `True`

whether or not to automatically add a manual tag to the generated targets
Links tagged "manual" dy default is desirable so that they are not built by `bazel build ...` if they
are unused downstream. For 3rd party deps, this is particularly important so that 3rd party deps are
not fetched at all unless they are used.





### visibility

Optional. Default: `["//visibility:public"]`

the visibility of the link target





### kwargs

Optional. 

see attributes of npm_package_store rule





## stamped_package_json

Convenience wrapper to set the "version" property in package.json with the git tag.

In unstamped builds (typically those without `--stamp`) the version will be set to `0.0.0`.
This ensures that actions which use the package.json file can get cache hits.

For more information on stamping, read https://docs.aspect.build/rules/aspect_bazel_lib/docs/stamping.


 

### name

Required. 

name of the resulting `jq` target, must be "package"





### stamp_var

Required. 

a key from the bazel-out/stable-status.txt or bazel-out/volatile-status.txt files





### kwargs

Optional. 

additional attributes passed to the jq rule, see https://docs.aspect.build/rules/aspect_bazel_lib/docs/jq







