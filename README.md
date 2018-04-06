# nimpb_build

**NOTE** nimpb_build is still experimental :-)

A tool for generating suitable Nim code for
[nimpb](https://github.com/oswjk/nimpb). It uses a prebuilt and bundled protoc
compiler. This tool supports the following platforms:

- Linux x86_32
- Linux x86_64
- Linux aarch_64
- OSX x86_64
- Windows

nimpb_build is modeled somewhat after [prost-build](https://github.com/danburkert/prost).

# Install with Nimble

    $ nimble install https://github.com/oswjk/nimpb_build

# Usage

## As a binary

Using the tool is simple:

    $ nimpb_build -I. --out=. my.proto

It's almost like using protoc directly. In fact, the arguments are basically
passed along to protoc.

You can specify nimpb_build as a dependency for your project in your .nimble
file and create a task for generating code:

    requires "nimpb_build"

    task proto, "Process .proto files":
        exec "nimpb_build -I. --out=. my.proto"

## As a library

It's also possible to use nimpb_build as a library:

```nim
import nimpb_build

let protos = @["my.proto"]
let incdirs = @["."]
let outdir = "."

compileProtos(protos, incdirs, outdir)
```

# How it works

nimpb_build invokes the protoc compiler with `--descriptor_set_out` parameter,
which makes protoc output a `FileDescriptorSet` (defined [here](src/nimpb_buildpkg/protobuf/include/google/protobuf/descriptor.proto)) into a file. nimpb_build then reads and parses the file,
and generates Nim code from the parsed definitions.
