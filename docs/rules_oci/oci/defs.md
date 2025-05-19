<!-- Generated with rules_docgen: http://github.com/aspect-build/rules_docgen -->

To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_oci//oci:defs.bzl", ...)
```

Rules
=====


## oci_tarball_rule

Loads an OCI layout into a container daemon without needing to publish the image first.

Passing anything other than oci_image to the image attribute will lead to build time errors.

### Build Outputs

The default output is an mtree specification file.
This is because producing the tarball in `bazel build` is expensive, and should typically not be an input to any other build actions,
so producing it only creates unnecessary load on the action cache.

If needed, the `tarball` output group allows you to depend on the tar output from another rule.

On the command line, `bazel build //path/to:my_tarball --output_groups=+tarball`

or in a BUILD file:

```starlark
oci_load(
    name = "my_tarball",
    ...
)
filegroup(
    name = "my_tarball.tar",
    srcs = [":my_tarball"],
    output_group = "tarball",
)
```

### When using `format = "oci"`

When using format = oci, containerd image store needs to be enabled in order for the oci style tarballs to work.

On docker desktop this can be enabled by visiting `Settings (cog icon) -> Features in development -> Use containerd for pulling and storing images`

For more information, see https://docs.docker.com/desktop/containerd/

### Multiple images

To load more than one image into the daemon,
use [rules_multirun] to group multiple oci_load targets into one executable target.

This might be useful with a docker-compose workflow, for example.

```starlark
load("@rules_multirun//:defs.bzl", "command", "multirun")

IMAGES = {
    "webservice": "//path/to/web-service:image.load",
    "backend": "//path/to/backend-service:image.load",
}

[
    command(
        name = k,
        command = v,
    )
    for (k, v) in IMAGES.items()
]

multirun(
    name = "load_all",
    commands = IMAGES.keys(),
)
```

[rules_multirun]: https://github.com/keith/rules_multirun


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### format

Optional string.
Default: `"docker"`



Format of image to generate. Options are: docker, oci. Currently, when the input image is an image_index, only oci is supported, and when the input image is an image, only docker is supported. Conversions between formats may be supported in the future.


### image

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




Label of a directory containing an OCI layout, typically `oci_image`


### repo_tags

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




a file containing repo_tags, one per line.


### loader

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Alternative target for a container cli tool that will be
used to load the image into the local engine when using `bazel run` on this target.

By default, we look for `docker` or `podman` on the PATH, and run the `load` command.

See the _run_template attribute for the script that calls this loader tool.


## oci_image_rule

Build an OCI compatible container image.

Note, most users should use the wrapper macro instead of this rule directly.
See [oci_image](#oci_image).

It takes number of tar files as layers to create image filesystem.
For incrementality, use more fine-grained tar files to build up the filesystem,
and choose an order so that less-frequently changed files appear earlier in the list.

```starlark
oci_image(
    # do not sort
    tars = [
        "rootfs.tar",
        "appfs.tar",
        "libc6.tar",
        "passwd.tar",
    ]
)
```

To base an oci_image on another oci_image, the `base` attribute can be used.

```starlark
oci_image(
    base = "//sys:base",
    tars = [
        "appfs.tar"
    ]
)
```

To combine `env` with environment variables from the `base`, bash style variable syntax can be used.

```starlark
oci_image(
    name = "base",
    env = {"PATH": "/usr/bin"}
)

oci_image(
    name = "app",
    base = ":base",
    env = {"PATH": "/usr/local/bin:$PATH"}
)
```


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### base

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



Label to an oci_image target to use as the base.


### created

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



The datetime when the image was created. This can be a file containing a string in the format `YYYY-MM-DDTHH:MM:SS.sssZ`
Typically, you'd provide a file containing a stamp variable replaced by the datetime of the build
when executed with `--stamp`.


### tars

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`



List of tar files to add to the image as layers.
Do not sort this list; the order is preserved in the resulting image.
Less-frequently changed files belong in lower layers to reduce the network bandwidth required to pull and push.

The authors recommend [dive](https://github.com/wagoodman/dive) to explore the layering of the resulting image.


### entrypoint

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a newline separated list to be used as the `entrypoint` to execute when the container starts. These values act as defaults and may be replaced by an entrypoint specified when creating a container. NOTE: Setting this attribute will reset the `cmd` attribute


### cmd

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a newline separated list to be used as the `command & args` of the container. These values act as defaults and may be replaced by any specified when creating a container.


### env

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing the default values for the environment variables of the container. These values act as defaults and are merged with any specified when creating a container. Entries replace the base environment variables if any of the entries has conflicting keys.
To merge entries with keys specified in the base, `${KEY}` or `$KEY` syntax may be used.


### user

Optional string.
Default: `""`



The `username` or `UID` which is a platform-specific structure that allows specific control over which user the process run as.
This acts as a default value to use when the value is not specified when creating a container.
For Linux based systems, all of the following are valid: `user`, `uid`, `user:group`, `uid:gid`, `uid:group`, `user:gid`.
If `group/gid` is not specified, the default group and supplementary groups of the given `user/uid` in `/etc/passwd` from the container are applied.


### workdir

Optional string.
Default: `""`



Sets the current working directory of the `entrypoint` process in the container. This value acts as a default and may be replaced by a working directory specified when creating a container.


### exposed_ports

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a comma separated list of exposed ports. (e.g. 2000/tcp, 3000/udp or 4000. No protocol defaults to tcp).


### volumes

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a comma separated list of volumes. (e.g. /srv/data,/srv/other-data)


### os

Optional string.
Default: `""`



The name of the operating system which the image is built to run on. eg: `linux`, `windows`. See $GOOS documentation for possible values: https://go.dev/doc/install/source#environment


### architecture

Optional string.
Default: `""`



The CPU architecture which the binaries in this image are built to run on. eg: `arm64`, `arm`, `amd64`, `s390x`. See $GOARCH documentation for possible values: https://go.dev/doc/install/source#environment


### variant

Optional string.
Default: `""`



The variant of the specified CPU architecture. eg: `v6`, `v7`, `v8`. See: https://github.com/opencontainers/image-spec/blob/main/image-index.md#platform-variants for more.


### labels

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a dictionary of labels. Each line should be in the form `name=value`.


### annotations

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



A file containing a dictionary of annotations. Each line should be in the form `name=value`.


### resource_set

Optional string.
Default: `"default"`



A predefined function used as the resource_set for actions.

Used with --experimental_action_resource_set to reserve more RAM/CPU, preventing Bazel overscheduling resource-intensive actions.

By default, Bazel allocates 1 CPU and 250M of RAM.
https://github.com/bazelbuild/bazel/blob/058f943037e21710837eda9ca2f85b5f8538c8c5/src/main/java/com/google/devtools/build/lib/actions/AbstractAction.java#L77


## oci_image_index_rule

Build a multi-architecture OCI compatible container image.

It takes number of `oci_image` targets to create a fat multi-architecture image conforming to [OCI Image Index Specification](https://github.com/opencontainers/image-spec/blob/main/image-index.md).

Image indexes can be created in two ways:

## Using Bazel platforms

While this feature is still experimental, it is the recommended way to create image indexes.

```starlark
go_binary(
    name = "app_can_cross_compile"
)

tar(
    name = "app_layer",
    srcs = [
        ":app_can_cross_compile",
    ],
)

oci_image(
    name = "image",
    tars = [":app_layer"],
)

oci_image_index(
    name = "image_multiarch",
    images = [":image"],
    platforms = [
        "@rules_go//go/toolchain:linux_amd64",
        "@rules_go//go/toolchain:linux_arm64",
    ],
)
```

## Without using Bazel platforms

```starlark
oci_image(
    name = "app_linux_amd64"
)

oci_image(
    name = "app_linux_arm64"
)

oci_image_index(
    name = "app",
    images = [
        ":app_linux_amd64",
        ":app_linux_arm64"
    ]
)
```


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### images

Required <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.




List of labels to oci_image targets.


### platforms

Optional <a href="https://bazel.build/docs/build-ref.html#labels">list of labels</a>.
Default: `[]`

[Must provide `PlatformInfo`] 

This feature is highly EXPERIMENTAL and not subject to our usual SemVer guarantees.
A list of platform targets to build the image for. If specified, only one image can be specified in the images attribute.


## oci_push_rule

Push an oci_image or oci_image_index to a remote registry.

Internal rule used by the [oci_push macro](/docs/push.md#oci_push).
Most users should use the macro.

Authorization
=============

By default, oci_push uses the standard authorization config file located on the host where `oci_push` is running.
Therefore the following documentation may be consulted:

- https://docs.docker.com/engine/reference/commandline/login/
- https://docs.podman.io/en/latest/markdown/podman-login.1.html
- https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_auth_login.md

Behavior
========

Pushing and tagging are performed sequentially which MAY lead to non-atomic pushes if one the following events occur;

- Remote registry rejects a tag due to various reasons. eg: forbidden characters, existing tags
- Remote registry closes the connection during the tagging
- Local network outages

In order to avoid incomplete pushes oci_push will push the image by its digest and then apply the `remote_tags` sequentially at
the remote registry.

Any failure during pushing or tagging will be reported with non-zero exit code and cause remaining steps to be skipped.

Usage
=====

When running the pusher, you can pass flags to `bazel run`.

1. Override `repository` by passing the `-r|--repository` flag.

e.g. `bazel run //myimage:push -- --repository index.docker.io/<ORG>/image`

2. Supply tags in addition to `remote_tags` by passing the `-t|--tag` flag.

e.g. `bazel run //myimage:push -- --tag latest`

Examples
========

Push an oci_image to docker registry with 'latest' tag

```starlark
oci_image(name = "image")

oci_push(
    name = "push",
    image = ":image",
    repository = "index.docker.io/<ORG>/image",
    remote_tags = ["latest"]
)
```

Push a multi-architecture image to github container registry with a semver tag

Refer to [oci_image_index](/docs/image_index.md) for more details on how to create a multi-architecture image.

```starlark
load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template_rule")

oci_image(name = "app_linux_arm64")

oci_image(name = "app_linux_amd64")

oci_image(name = "app_windows_amd64")

oci_image_index(
    name = "app_image",
    images = [
        ":app_linux_arm64",
        ":app_linux_amd64",
        ":app_windows_amd64",
    ]
)

# Use the value of --embed_label under --stamp, otherwise use a deterministic constant
# value to ensure cache hits for actions that depend on this.
expand_template(
    name = "stamped",
    out = "_stamped.tags.txt",
    template = ["0.0.0"],
    stamp_substitutions = {"0.0.0": "{{BUILD_EMBED_LABEL}}"},
)

oci_push(
    name = "push",
    image = ":app_image",
    repository = "ghcr.io/<OWNER>/image",
    remote_tags = ":stamped",
)
```

To push to more than one registry, or using multiple remote tags,
use [rules_multirun] to group multiple oci_push targets into one executable target.

For example:

```starlark
load("@rules_multirun//:defs.bzl", "command", "multirun")

REPOS = {
    "index": "index.docker.io/<ORG>/image",
    "ECR": "aws_account_id.dkr.ecr.us-west-2.amazonaws.com",
}

[
    oci_push(
        name = "push_image_" + k,
        image = ":image_index",
        remote_tags = ":stamped",
        repository = v,
    )
    for (k, v) in REPOS.items()
]

[
    command(
        name = k,
        command = "push_image_" + k,
    )
    for k in REPOS.keys()
]

multirun(
    name = "push_all",
    commands = REPOS.keys(),
)
```

[rules_multirun]: https://github.com/keith/rules_multirun


### name

Required <a href="https://bazel.build/docs/build-ref.html#name">name</a>.




A unique name for this target.


### image

Required <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.




Label to an oci_image or oci_image_index


### repository

Optional string.
Default: `""`



Repository URL where the image will be signed at, e.g.: `index.docker.io/<user>/image`.
Digests and tags are not allowed.


### repository_file

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



The same as 'repository' but in a file. This allows pushing to different repositories based on stamping.


### remote_tags

Optional <a href="https://bazel.build/docs/build-ref.html#labels">label</a>.
Default: `None`



a text file containing tags, one per line.
These are passed to [`crane tag`](
https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_tag.md)




# Macros and Functions


## oci_image_index

Macro wrapper around [oci_image_index_rule](#oci_image_index_rule).

Produces a target `[name].digest`, whose default output is a file containing the sha256 digest of the resulting image.
This is the same output as for the `oci_image` macro.


 

### name

Required. 

name of resulting oci_image_index_rule





### kwargs

Optional. 

other named arguments to [oci_image_index_rule](#oci_image_index_rule) and
[common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).





## oci_image

Macro wrapper around [oci_image_rule](#oci_image_rule).

Allows labels and annotations to be provided as a dictionary, in addition to a text file.
See https://github.com/opencontainers/image-spec/blob/main/annotations.md

Label/annotation/env can by configured using either dict(key->value) or a file that contains key=value pairs
(one per line). The file can be preprocessed using (e.g. using `jq`) to supply external (potentially not
deterministic) information when running with `--stamp` flag.  See the example in
[/examples/labels/BUILD.bazel](https://github.com/bazel-contrib/rules_oci/blob/main/examples/labels/BUILD.bazel).

Produces a target `[name].digest`, whose default output is a file containing the sha256 digest of the resulting image.
This is similar to the same-named target created by rules_docker's `container_image` macro.


 

### name

Required. 

name of resulting oci_image_rule





### created

Optional. Default: `None`

Label to a file containing a single datetime string.
The content of that file is used as the value of the `created` field in the image config.





### labels

Optional. Default: `None`

Labels for the image config.
May either be specified as a file, as with the documentation above, or a dict of strings to specify values inline.





### annotations

Optional. Default: `None`

Annotations for the image config.
May either be specified as a file, as with the documentation above, or a dict of strings to specify values inline.





### env

Optional. Default: `None`

Environment variables provisioned by default to the running container.
May either be specified as a file, as with the documentation above, or a dict of strings to specify values inline.





### cmd

Optional. Default: `None`

Command & argument configured by default in the running container.
May either be specified as a file, as with the documentation above. or a list of strings to specify values inline.





### entrypoint

Optional. Default: `None`

Entrypoint configured by default in the running container.
May either be specified as a file, as with the documentation above. or a list of strings to specify values inline.





### exposed_ports

Optional. Default: `None`

Exposed ports in the running container.
May either be specified as a file, as with the documentation above. or a list of strings to specify values inline.





### volumes

Optional. Default: `None`

Volumes for the container.
May either be specified as a file, as with the documentation above. or a list of strings to specify values inline.





### kwargs

Optional. 

other named arguments to [oci_image_rule](#oci_image_rule) and
[common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).





## oci_push

Macro wrapper around [oci_push_rule](#oci_push_rule).

Allows the remote_tags attribute to be a list of strings in addition to a text file.


 

### name

Required. 

name of resulting oci_push_rule





### remote_tags

Optional. Default: `None`

a list of tags to apply to the image after pushing,
or a label of a file containing tags one-per-line.
See [stamped_tags](https://github.com/bazel-contrib/rules_oci/blob/main/examples/push/stamp_tags.bzl)
as one example of a way to produce such a file.





### kwargs

Optional. 

other named arguments to [oci_push_rule](#oci_push_rule) and
[common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).





## oci_load

Macro wrapper around [oci_tarball_rule](#oci_tarball_rule).

Allows the repo_tags attribute to be a list of strings in addition to a text file.


 

### name

Required. 

name of resulting oci_tarball_rule





### repo_tags

Optional. Default: `None`

a list of repository:tag to specify when loading the image,
or a label of a file containing tags one-per-line.
See [stamped_tags](https://github.com/bazel-contrib/rules_oci/blob/main/examples/push/stamp_tags.bzl)
as one example of a way to produce such a file.





### kwargs

Optional. 

other named arguments to [oci_tarball_rule](#oci_tarball_rule) and
[common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).







