# Package

version       = "0.1.0"
author        = "Oskari Timperi"
description   = "Protocol Buffers compiler for nimpb"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.18.0"

task fetch, "fetch prebuilt protoc binaries":
    exec "nim c -d:ssl -r fetch"
