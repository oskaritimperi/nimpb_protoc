import os
import osproc
import streams
import strformat
import strtabs
import strutils

from nimpb_buildpkg/plugin import pluginMain

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

proc findCompiler(): string =
    let
        compilerName = &"protoc-{compilerId}{exeSuffix}"
        paths = @[
            getAppDir() / "src" / "nimpb_buildpkg" / "protobuf",
            getAppDir() / "nimpb_buildpkg" / "protobuf",
        ]

    for path in paths:
        if fileExists(path / compilerName):
            return path / compilerName

    raise newException(Exception, &"{compilerName} not found!")

proc builtinIncludeDir(compilerPath: string): string =
    parentDir(compilerPath) / "include"

template verboseEcho(x: untyped): untyped =
    if verbose:
        echo(x)

proc compileProtos*(protos: openArray[string], outdir: string,
                    includes: openArray[string], verbose: bool) =
    let command = findCompiler()
    var baseArgs: seq[string] = @[]

    add(baseArgs, &"--plugin=protoc-gen-nim={getAppFilename()}")

    for incdir in includes:
        verboseEcho(&"Adding include directory: {incdir}")
        add(baseArgs, &"-I{incdir}")

    add(baseArgs, &"-I{builtinIncludeDir(command)}")
    verboseEcho(&"Adding include directory: {builtinIncludeDir(command)}")

    add(baseArgs, &"--nim_out={outdir}")
    verboseEcho(&"Output directory: {outdir}")

    for proto in protos:
        var args = baseArgs
        add(args, proto)
        var options = {poStdErrToStdOut}
        if verbose:
            incl(options, poEchoCmd)

        let env = newStringTable("NIMPB_BUILD_PLUGIN", "1", modeCaseSensitive)

        let process = startProcess(command, workingDir="", args=args, env=env,
            options=options)
        var outp = outputStream(process)
        var outputData: string = ""
        var line = newStringOfCap(120)
        while true:
            if outp.readLine(line):
                add(outputData, line)
                add(outputData, "\n")
            elif not running(process):
                break
        var rc = peekExitCode(process)
        close(process)

        if rc != 0:
            echo(outputData)
            quit(QuitFailure)
        else:
            verboseEcho(outputData)


proc usage() {.noreturn.} =
    echo(&"""
{getAppFilename()} --out=OUTDIR [-IPATH [-IPATH]...] PROTOFILE...

    --out       The output directory for the generated files
    -I          Add a path to the set of include paths
""")
    quit(QuitFailure)

when isMainModule:
    if getEnv("NIMPB_BUILD_PLUGIN", "") == "1":
        pluginMain()
        quit(QuitSuccess)

    var includes: seq[string] = @[]
    var protos: seq[string] = @[]
    var outdir: string
    var verbose = false

    if paramCount() == 0:
        usage()

    for idx in 1..paramCount():
        let param = paramStr(idx)

        if param.startsWith("-I"):
            add(includes, param[2..^1])
        elif param.startsWith("--out="):
            outdir = param[6..^1]
        elif param == "--verbose":
            verbose = true
        elif param == "--help":
            usage()
        else:
            add(protos, param)

    if outdir == nil:
        echo("error: --out is required")
        quit(QuitFailure)

    if len(protos) == 0:
        echo("error: no input files")
        quit(QuitFailure)

    compileProtos(protos, outdir, includes, verbose)
