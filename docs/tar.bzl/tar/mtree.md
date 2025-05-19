<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

Helpers for mtree(8), see https://man.freebsd.org/cgi/man.cgi?mtree(8)

### Mutating the tar contents

The `mtree_spec` rule can be used to create an mtree manifest for the tar file.
Then you can mutate that spec using `mtree_mutate` and feed the result
as the `mtree` attribute of the `tar` rule.

For example, to set the owner uid of files in the tar, you could:

```starlark
_TAR_SRCS = ["//some:files"]

mtree_spec(
    name = "mtree",
    srcs = _TAR_SRCS,
)

mtree_mutate(
    name = "change_owner",
    mtree = ":mtree",
    owner = "1000",
)

tar(
    name = "tar",
    srcs = _TAR_SRCS,
    mtree = "change_owner",
)
```

Rules
=====


## mtree_spec

Create an mtree specification to map a directory hierarchy. See https://man.freebsd.org/cgi/man.cgi?mtree(8)


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### srcs

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Files that are placed into the tar


### out

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Resulting specification file to write


### include_runfiles

Optional boolean.
Default: `True`



Include the runfiles tree in the resulting mtree for targets that are executable.

The runfiles are in the paths that Bazel uses. For example, for the
target `//my_prog:foo`, we would see files under paths like
`foo.runfiles/<repo name>/my_prog/<file>`




# Macros and Functions


## mtree_mutate

Modify metadata in an mtree file.

 

### name

Required. 

name of the target, output will be `[name].mtree`.





### mtree

Required. 

input mtree file, typically created by `mtree_spec`.





### srcs

Optional. Default: `None`

list of files to resolve symlinks for.





### preserve_symlinks

Optional. Default: `False`

`EXPERIMENTAL!` We may remove or change it at any point without further notice. Flag to determine whether to preserve symlinks in the tar.





### strip_prefix

Optional. Default: `None`

prefix to remove from all paths in the tar. Files and directories not under this prefix are dropped.





### package_dir

Optional. Default: `None`

directory prefix to add to all paths in the tar.





### mtime

Optional. Default: `None`

new modification time for all entries.





### owner

Optional. Default: `None`

new uid for all entries.





### ownername

Optional. Default: `None`

new uname for all entries.





### awk_script

Optional. Default: `Label("@tar.bzl//tar/private:modify_mtree.awk")`

may be overridden to change the script containing the modification logic.





### kwargs

Optional. 

additional named parameters to genrule





## mutate

Factory function to make a partially-applied `mtree_mutate` rule.

 

### kwargs

Optional. 









