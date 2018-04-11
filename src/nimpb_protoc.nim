import os
import strformat

when defined(windows):
    const compilerId = "win32"
elif defined(linux):
    when defined(i386):
        const arch = "x86_32"
    elif defined(amd64):
        const arch = "x86_64"
    elif defined(arm64):
        const arch = "aarch_64"
    else:
        {.fatal:"unsupported architecture".}
    const compilerId = "linux-" & arch
elif defined(macosx):
    when defined(amd64):
        const arch = "x86_64"
    else:
        {.fatal:"unsupported architecture".}
    const compilerId = "osx-" & arch
else:
    {.fatal:"unsupported platform".}

when defined(windows):
    const exeSuffix = ".exe"
else:
    const exeSuffix = ""

let
    paths = @[
        # getAppDir() / "src" / "nimpb_protocpkg" / "protobuf",
        # getAppDir() / "nimpb_protocpkg" / "protobuf",
        parentDir(currentSourcePath()) / "nimpb_protocpkg" / "protobuf",
    ]

proc getCompilerPath*(): string =
    let
        compilerName = &"protoc-{compilerId}{exeSuffix}"

    for path in paths:
        if fileExists(path / compilerName):
            return path / compilerName

    raise newException(Exception, &"{compilerName} not found!")

proc getProtoIncludeDir*(): string =
    for path in paths:
        if dirExists(path / "include"):
            return path / "include"
