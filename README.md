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

Using the tool is simple:

    $ nimpb_build -I. --out=. my.proto

It's almost like using protoc directly. In fact, the arguments are basically
passed along to protoc.

You can specify nimpb_build as a dependency for your project in your .nimble
file and create a task for generating code:

    requires "nimpb_build"

    task proto, "Process .proto files":
        exec "nimpb_build -I. --out=. my.proto"

# How it works

nimpb_build includes functionality to invoke the protoc compiler. It also
includes a built-in protoc plugin, that protoc will use to generate the Nim
code.

First, nimpb_build will execute protoc with correct arguments. It will also
pass itself as a plugin using the --plugin argument to protoc. nimpb_build
will set the NIMPB_BUILD_PLUGIN=1 environment variable when executing protoc,
so that when protoc executes nimpb_build, the new nimpb_build instance knows
to work in protoc plugin mode.
