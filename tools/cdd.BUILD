# -*- mode: python -*-
# vi: set ft=python :

cc_library(
    name = "cdd",
    srcs = [
        "cddcore.c",
        "cddio.c",
        "cddlib.c",
        "cddlp.c",
        "cddmp.c",
        "cddproj.c",
        "setoper.c",
    ],
    hdrs = [
        "cdd.h",
        "cddmp.h",
        "cddtypes.h",
        "setoper.h",
    ],
    copts = [
        "-Wno-empty-body",
        "-Wno-format-extra-args",
        "-Wno-uninitialized",
    ],
    includes = ["."],
    licenses = ["restricted"],
    visibility = ["//visibility:public"],
)
