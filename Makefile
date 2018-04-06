VERSION = 3.5.1

nimpb_build: src/nimpb_build.nim src/nimpb_buildpkg/plugin.nim
	nim c -o:$@ $<

.PHONY: update-protoc
update-protoc: fetch
	./fetch $(VERSION)

fetch: fetch.nim
	nim c -d:ssl $<

.PHONY: update-descriptor
update-descriptor: src/nimpb_buildpkg/descriptor_pb.nim

src/nimpb_buildpkg/descriptor_pb.nim: src/nimpb_buildpkg/protobuf/include/google/protobuf/descriptor.proto nimpb_build
	./nimpb_build -Isrc/nimpb_buildpkg/protobuf/include/google/protobuf \
		--out=src/nimpb_buildpkg \
		src/nimpb_buildpkg/protobuf/include/google/protobuf/descriptor.proto
