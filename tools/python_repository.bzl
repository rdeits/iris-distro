# -*- mode: python -*-
# vi: set ft=python :

"""
Finds local system Python headers and libraries using python-config and
makes them available to be used as a C/C++ dependency.

Example:
    WORKSPACE:
        load("//tools:python_repository.bzl", "python_repository")
        python_repository(
            name = "foo",
            version = "2.7",
        )

    BUILD:
        cc_library(
            name = "foobar",
            deps = ["@foo//:python"],
            srcs = ["bar.cc"],
        )

Argument:
    name: A unique name for this rule.
    version: The version of Python headers and libraries to be found.
"""

def _impl(repository_ctx):
    python_config = repository_ctx.which("python{}-config".format(
        repository_ctx.attr.version))

    if not python_config:
        fail("Could NOT find python{}-config".format(
            repository_ctx.attr.version))

    result = repository_ctx.execute([python_config, "--includes"])

    if result.return_code != 0:
        fail("Could NOT determine includes", attr=result.stderr)

    cflags = result.stdout.strip().split(" ")
    cflags = [cflag for cflag in cflags if cflag]

    root = repository_ctx.path("")
    base = root.get_child("include")
    root_len = len(str(base)) - 7

    includes = []

    for cflag in cflags:
        if cflag.startswith("-I"):
            source = repository_ctx.path(cflag[2:])
            destination = base.get_child(str(source).replace("/", "_"))
            include = str(destination)[root_len:]

            if include not in includes:
                repository_ctx.symlink(source, destination)
                includes += [include]

    result = repository_ctx.execute([python_config, "--ldflags"])

    if result.return_code != 0:
        fail("Could NOT determine linkopts", attr=result.stderr)

    linkopts = result.stdout.strip().split(" ")
    linkopts = [linkopt for linkopt in linkopts if linkopt]

    for i in reversed(range(len(linkopts))):
        if not linkopts[i].startswith("-"):
            linkopts[i - 1] += " " + linkopts.pop(i)

    repository_ctx.file("empty.cc", executable=False)

    file_content = """
cc_library(
    name = "python",
    srcs = ["empty.cc"],
    hdrs = glob(["include/**"]),
    includes = {},
    linkopts = {},
    visibility = ["//visibility:public"],
)
    """.format(includes, linkopts)

    repository_ctx.file("BUILD", content=file_content, executable=False)

python_repository = repository_rule(
    _impl,
    attrs = {"version": attr.string(default="2.7")},
    local = True,
)
