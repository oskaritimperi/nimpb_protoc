import httpclient
import os
import osproc
import strformat

if paramCount() != 1:
    echo(&"usage: {extractFilename(getAppFilename())} <version>")
    quit(QuitFailure)

var version = paramStr(1)

const
    BaseUrl = "https://github.com/google/protobuf/releases/download"
    Systems = [
        "linux-aarch_64",
        "linux-x86_32",
        "linux-x86_64",
        "osx-x86_64",
        "win32",
    ]

proc zipName(identifier: string): string =
    &"protoc-{version}-{identifier}.zip"

proc exeSuffix(identifier: string): string =
    result = ""
    if identifier == "win32":
        result = ".exe"

proc compilerName(identifier: string): string =
    &"protoc-{identifier}{exeSuffix(identifier)}"

proc downloadFile(url, target: string) =
    let
        client = newHttpClient()
    echo(&"downloading {url} -> {target}")
    if not fileExists(target):
        downloadFile(client, url, target)

proc downloadRelease(identifier: string) =
    let
        url = &"{BaseUrl}/v{version}/{zipName(identifier)}"
        target = zipName(identifier)
    downloadFile(url, target)

proc downloadSources() =
    let url = &"https://github.com/google/protobuf/archive/v{version}.zip"
    downloadFile(url, &"v{version}.zip")

proc extractCompiler(identifier: string) =
    echo(&"extracting compiler: {identifier}")
    createDir("src/nimpb_buildpkg/protobuf")
    let args = @["-j", "-o", zipName(identifier), &"bin/protoc{exeSuffix(identifier)}"]
    discard execProcess("unzip", args, nil, {poStdErrToStdout, poUsePath})
    moveFile(&"protoc{exeSuffix(identifier)}", &"src/nimpb_buildpkg/protobuf/{compilerName(identifier)}")

proc extractIncludes() =
    echo("extracting includes")
    createDir("src/nimpb_buildpkg/protobuf")
    let args = @["-o", zipName("linux-x86_64"), "include/*", "-d", "src/nimpb_buildpkg/protobuf"]
    discard execProcess("unzip", args, nil, {poStdErrToStdout, poUsePath})

proc extractLicense() =
    echo("extracting LICENSE")
    let args = @["-o", "-j", &"v{version}.zip", &"protobuf-{version}/LICENSE", "-d", "src/nimpb_buildpkg/protobuf"]
    discard execProcess("unzip", args, nil, {poStdErrToStdout, poUsePath})

for system in Systems:
    downloadRelease(system)
    extractCompiler(system)

downloadSources()

extractIncludes()
extractLicense()
