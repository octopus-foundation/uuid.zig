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
const uuid = @import("v4.zig");

test "bytes -> uuid" {
    const parsed = try uuid.fromBytes(&[_]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x46, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    });
    try std.testing.expect(parsed == 0x000102030405460708090a0b0c0d0e0f);
}

test "uuid -> bytes" {
    const src = [16]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x46, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    };

    const id = try uuid.fromBytes(&src);
    var dest: [16]u8 = undefined;
    uuid.toBytes(id, &dest);

    try std.testing.expectEqualSlices(u8, &dest, &src);
}

test "uuid -> str" {
    const id: uuid.UUID = 0x000102030405060708090a0b0c0d0e0f;

    var dest: [36]u8 = undefined;
    uuid.toString(id, &dest);

    try std.testing.expectEqualSlices(u8, &dest, "00010203-0405-0607-0809-0a0b0c0d0e0f");
}

test "str -> uuid" {
    const parsed = try uuid.fromString("00010203-0405-4607-0809-0A0B0C0D0E0F");
    try std.testing.expect(parsed == 0x000102030405460708090a0b0c0d0e0f);
}

test "random uuid" {
    var rng = std.Random.DefaultPrng.init(0);
    const id = uuid.random(rng.random());

    var dest: [36]u8 = undefined;
    uuid.toString(id, &dest);

    try std.testing.expect((id >> 76) & 0xf == 4);
}

test "crypto random uuid" {
    const id = uuid.random(std.crypto.random);

    var dest: [36]u8 = undefined;
    uuid.toString(id, &dest);

    try std.testing.expect((id >> 76) & 0xf == 4);
}

test "invalid string format" {
    try std.testing.expectError(uuid.Error.InvalidBufferSize, uuid.fromString("invalid"));
    try std.testing.expectError(uuid.Error.InvalidCharacter, uuid.fromString("0001020304054607-0809-0A0B-0C0D-0E0F"));
    try std.testing.expectError(uuid.Error.NotV4, uuid.fromString("00010203-0405-FFFF-0809-0A0B0C0D0E0F"));
    try std.testing.expectError(uuid.Error.InvalidCharacter, uuid.fromString("GHIJKLMN-OPQR-STUV-WXYZ-abcdefghijkl"));
}

test "invalid byte format" {
    try std.testing.expectError(uuid.Error.InvalidBufferSize, uuid.fromBytes(&[_]u8{0}));
    try std.testing.expectError(uuid.Error.NotV4, uuid.fromBytes(&[_]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    }));
}

test "case insensitive" {
    const lower = try uuid.fromString("00010203-0405-4607-0809-0a0b0c0d0e0f");
    const upper = try uuid.fromString("00010203-0405-4607-0809-0A0B0C0D0E0F");
    try std.testing.expectEqual(lower, upper);
}
