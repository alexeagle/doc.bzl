<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

A test rule that invokes the [Bash Automated Testing System](https://github.com/bats-core/bats-core).

For example, a `bats_test` target containing a single .bat and basic configuration:

```starlark
bats_test(
    name = "my_test",
    size = "small",
    srcs = [
        "my_test.bats",
    ],
    data = [
        "data.bin",
    ],
    env = {
        "DATA_PATH": "$(location :data.bin)",
    },
    args = ["--timing"],
)
```

Rules
=====


## bats_test




### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### srcs

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Test files


### data

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



Runtime dependencies of the test.


### env

Optional <a href="https://bazel.build/docs/skylark/lib/dict.html">dictionary: String → String</a>.
Default: `{}`



Environment variables of the action.

Subject to [$(location)](https://bazel.build/reference/be/make-variables#predefined_label_variables)
and ["Make variable"](https://bazel.build/reference/be/make-variables) substitution.






