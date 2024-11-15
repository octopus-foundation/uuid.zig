//! UUID v4 implementation for Zig
//! Provides functionality to create, parse and format UUIDs according to RFC 4122.
//!
//! Example:
//! ```zig
//! var prng = std.rand.DefaultPrng.init(seed);
//! const uuid = v4.random(prng.random());
//!
//! var buf: [36]u8 = undefined;
//! v4.toString(uuid, &buf);
//! // buf now contains something like "550e8400-e29b-41d4-a716-446655440000"
//! ```

//               .'\   /`.
//             .'.-.`-'.-.`.
//        ..._:   .-. .-.   :_...
//      .'    '-.(o ) (o ).-'    `.
//     :  _    _ _`~(_)~`_ _    _  :
//    :  /:   ' .-=_   _=-. `   ;\  :
//    :   :|-.._  '     `  _..-|:   :
//     :   `:| |`:-:-.-:-:'| |:'   :
//      `.   `.| | | | | | |.'   .'
//        `.   `-:_| | |_:-'   .'
//          `-._   ````    _.-'
//              ``-------''
//
// Created by ab, 15.11.2024

const std = @import("std");

/// Possible errors when handling UUIDs
pub const Error = error{
    /// Buffer size doesn't match expected length (16 bytes for binary, 36 for string)
    InvalidBufferSize,
    /// String contains invalid characters
    InvalidCharacter,
    /// UUID version is not 4
    NotV4,
};

/// UUID is represented as a 128-bit integer
pub const UUID = u128;

/// Converts 16 bytes to UUID, verifying it's a v4 UUID
pub fn fromBytes(buf: []const u8) Error!UUID {
    if (buf.len != 16) return Error.InvalidBufferSize;
    if (buf[6] & 0xF0 != 0x40) return Error.NotV4;
    return std.mem.readInt(u128, buf[0..16], .big);
}

/// Converts UUID to 16 bytes
pub fn toBytes(uuid: UUID, target: *[16]u8) void {
    std.mem.writeInt(u128, target, uuid, .big);
}

const hex = "0123456789abcdef";

/// Converts UUID to canonical string representation
/// Format: 8-4-4-4-12 lowercase hex digits with hyphens
pub fn toString(uuid: UUID, buf: *[36]u8) void {
    byte2str(buf, 0, @truncate(uuid >> 120));
    byte2str(buf, 2, @truncate(uuid >> 112));
    byte2str(buf, 4, @truncate(uuid >> 104));
    byte2str(buf, 6, @truncate(uuid >> 96));

    buf[8] = '-';

    byte2str(buf, 9, @truncate(uuid >> 88));
    byte2str(buf, 11, @truncate(uuid >> 80));

    buf[13] = '-';

    byte2str(buf, 14, @truncate(uuid >> 72));
    byte2str(buf, 16, @truncate(uuid >> 64));

    buf[18] = '-';

    byte2str(buf, 19, @truncate(uuid >> 56));
    byte2str(buf, 21, @truncate(uuid >> 48));

    buf[23] = '-';

    byte2str(buf, 24, @truncate(uuid >> 40));
    byte2str(buf, 26, @truncate(uuid >> 32));
    byte2str(buf, 28, @truncate(uuid >> 24));
    byte2str(buf, 30, @truncate(uuid >> 16));
    byte2str(buf, 32, @truncate(uuid >> 8));
    byte2str(buf, 34, @truncate(uuid));
}

/// Parses UUID from string in canonical format
pub fn fromString(buf: []const u8) Error!UUID {
    if (buf.len != 36) {
        return Error.InvalidBufferSize;
    }

    if (buf[8] != '-' or buf[13] != '-' or buf[18] != '-' or buf[23] != '-') {
        return Error.InvalidCharacter;
    }

    var uuid: UUID = 0;
    for (buf) |c| {
        if (c == '-') continue;
        const digit = if (c >= '0' and c <= '9')
            c - '0'
        else if (c >= 'A' and c <= 'F')
            10 + (c - 'A')
        else if (c >= 'a' and c <= 'f')
            10 + (c - 'a')
        else
            return Error.InvalidCharacter;
        uuid = (uuid << 4) | digit;
    }

    // Version must be 0b0100 (4)
    if ((uuid >> 76) & 0xf != 4) {
        return Error.NotV4;
    }

    return uuid;
}

/// Generates random v4 UUID using provided random number generator
pub fn random(generator: anytype) UUID {
    var res = generator.int(u128);
    // Set version to 4
    res &= 0xffffffffffff0fffffffffffffffffff;
    res |= 0x00000000000040000000000000000000;
    return res;
}

inline fn byte2str(target: *[36]u8, offset: u8, value: u8) void {
    target[offset] = hex[value >> 4];
    target[offset + 1] = hex[value & 0xF];
}
