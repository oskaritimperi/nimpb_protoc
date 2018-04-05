# Package

version       = "0.1.0"
author        = "Oskari Timperi"
description   = "A Protocol Buffers code generator for nimpb"
license       = "MIT"
srcDir        = "src"
bin           = @["nimpb_build"]

# Dependencies

requires "nim >= 0.18.0"
requires "nimpb"

task fetch, "fetch prebuilt protoc binaries":
    exec "nim c -d:ssl -r fetch"
