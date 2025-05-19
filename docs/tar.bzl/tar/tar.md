<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

API for calling tar, see https://man.freebsd.org/cgi/man.cgi?tar(1)

Rules
=====


## tar_rule

Rule that executes BSD `tar`. Most users should use the [`tar`](#tar) macro, rather than load this directly.


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### args

Optional list of strings.
Default: `[]`



Additional flags permitted by BSD tar; see the man page.


### srcs

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Files, directories, or other targets whose default outputs are placed into the tar.

If any of the srcs are binaries with runfiles, those are copied into the resulting tar as well.


### mode

Optional string.
Default: `"create"`



A mode indicator from the following list, copied from the tar manpage:

- create: Create a new archive containing the specified items.

Other modes may be added in the future.


### mtree

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




An mtree specification file


### out

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Resulting tar file to write. If absent, `[name].tar` is written.


### compress

Optional string.
Default: `""`



Compress the archive file with a supported algorithm.


### compute_unused_inputs

Optional integer.
Default: `-1`



Whether to discover and prune input files that will not contribute to the archive.

Unused inputs are discovered by comparing the set of input files in `srcs` to the set
of files referenced by `mtree`. Files not used for content by the mtree specification
will not be read by the `tar` tool when creating the archive and can be pruned from the
input set using the `unused_inputs_list`
[mechanism](https://bazel.build/contribute/codebase#input-discovery).

Benefits: pruning unused input files can reduce the amount of work the build system must
perform. Pruned files are not included in the action cache key; changes to them do not
invalidate the cache entry, which can lead to higher cache hit rates. Actions do not need
to block on the availability of pruned inputs, which can increase the available
parallelism of builds. Pruned files do not need to be transferred to remote-execution
workers, which can reduce network costs.

Risks: pruning an actually-used input file can lead to unexpected, incorrect results. The
comparison performed between `srcs` and `mtree` is currently inexact and may fail to
handle handwritten or externally-derived mtree specifications. However, it is safe to use
this feature when the lines found in `mtree` are derived from one or more `mtree_spec`
rules, filtered and/or merged on whole-line basis only.

Possible values:

    - `compute_unused_inputs = 1`: Always perform unused input discovery and pruning.
    - `compute_unused_inputs = 0`: Never discover or prune unused inputs.
    - `compute_unused_inputs = -1`: Discovery and pruning of unused inputs is controlled by the
        --[no]@tar.bzl//tar:tar_compute_unused_inputs flag.




# Macros and Functions


## tar_lib.common.add_compression_args



 

### compress

Required. 







### args

Required. 







## tar_lib.implementation



 

### ctx

Required. 







## tar_lib.mtree_implementation



 

### ctx

Required. 







## tar

Wrapper macro around [`tar_rule`](#tar_rule).

### Options for mtree

mtree provides the "specification" or manifest of a tar file.
See https://man.freebsd.org/cgi/man.cgi?mtree(8)
Because BSD tar doesn't have a flag to set modification times to a constant,
we must always supply an mtree input to get reproducible builds.
See https://reproducible-builds.org/docs/archives/ for more explanation.

1. By default, mtree is "auto" which causes the macro to create an `mtree_spec` rule.

2. `mtree` may be supplied as an array literal of lines, e.g.

```
mtree =[
    "usr/bin uid=0 gid=0 mode=0755 type=dir",
    "usr/bin/ls uid=0 gid=0 mode=0755 time=0 type=file content={}/a".format(package_name()),
],
```

For the format of a line, see "There are four types of lines in a specification" on the man page for BSD mtree,
https://man.freebsd.org/cgi/man.cgi?mtree(8)

3. `mtree` may be a label of a file containing the specification lines.


 

### name

Required. 

name of resulting `tar_rule`





### mtree

Optional. Default: `"auto"`

"auto", or an array of specification lines, or a label of a file that contains the lines.
Subject to [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution.





### mutate

Optional. Default: `None`

a partially-applied `mtree_mutate` rule





### stamp

Optional. Default: `0`

should mtree attribute be stamped





### kwargs

Optional. 

additional named parameters to pass to `tar_rule`







