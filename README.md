# UUID v4

RFC 4122 compliant UUID v4 implementation in Zig.

## Features
- Zero dependencies
- Generate random UUIDs (v4)
- Parse from string/bytes
- Format to string/bytes
- No allocations
- Supports cryptographic RNG
- Tested on Zig 0.14.0-dev

## Install

```bash
zig fetch --save https://github.com/octopus-foundation/uuid.zig/archive/refs/tags/0.0.0.tar.gz
```

In your `build.zig`:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uuid = b.dependency("uuid", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("uuid", uuid.module("uuid"));
    b.installArtifact(exe);
}
```

## Usage

```zig
const uuid = @import("uuid").v4;

// Generate random UUID
var prng = std.Random.DefaultPrng.init(0);
const id = uuid.random(prng.random());

// Format as string
var buf: [36]u8 = undefined;
uuid.toString(id, &buf);
// "550e8400-e29b-41d4-a716-446655440000"

// Parse from string 
const parsed = try uuid.fromString("550e8400-e29b-41d4-a716-446655440000");

// Convert to/from bytes
var bytes: [16]u8 = undefined;
uuid.toBytes(id, &bytes);
const fromBytes = try uuid.fromBytes(&bytes);

// With crypto random
const crypto_id = uuid.random(std.crypto.random);
```