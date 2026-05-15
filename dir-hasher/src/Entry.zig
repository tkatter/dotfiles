const Entry = @This();

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const Blake3 = std.crypto.hash.Blake3;

const print = std.debug.print;

kind: Io.File.Kind,
path: []u8,
hash: ?[32]u8 = null,

pub fn deinit(self: *const Entry, gpa: Allocator) void {
    gpa.free(self.path);
}

pub fn fromWalkerEntry(alloc: Allocator, base_dir: []const u8, walker_entry: *const Io.Dir.Walker.Entry) !Entry {
    return Entry{
        .kind = walker_entry.kind,
        .path = try std.fs.path.join(alloc, &[_][]const u8{ base_dir, walker_entry.path }),
    };
}

pub fn doHash(self: *Entry, io: Io, hasher: *Blake3, buf: []u8) !void {
    if (self.kind == .directory) return;

    const file = if (std.fs.path.isAbsolute(self.path))
        try Io.Dir.openFileAbsolute(io, self.path, .{})
    else
        try Io.Dir.cwd().openFile(io, self.path, .{});
    defer file.close(io);

    var file_reader = file.reader(io, &.{});
    const reader = &file_reader.interface;
    var bytes_read: usize = try reader.readSliceShort(buf);

    while (bytes_read > 0) {
        hasher.update(buf[0..bytes_read]);
        bytes_read = try reader.readSliceShort(buf);
    }

    var h: [32]u8 = undefined;

    hasher.final(&h);
    hasher.reset();

    self.hash = h;
}
