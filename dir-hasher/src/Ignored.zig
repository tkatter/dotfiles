const Ignored = @This();

const std = @import("std");
const fs = std.fs;
const Io = std.Io;
const Allocator = std.mem.Allocator;

const print = std.debug.print;
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;
const containsAtLeast = std.mem.containsAtLeast;

list: std.ArrayList([]const u8) = .empty,
io: Io,
gpa: Allocator,

pub fn init(io: Io, gpa: Allocator) Ignored {
    return .{ .io = io, .gpa = gpa };
}

pub fn deinit(self: *Ignored) void {
    for (self.list.items) |segment| self.gpa.free(segment);
    self.list.deinit(self.gpa);
}

pub fn default(self: *Ignored) !void {
    return self.fromFile(".gitignore") catch |err| {
        switch (err) {
            error.FileNotFound => return,
            else => return err,
        }
    };
}

pub fn addSegment(self: *Ignored, segment: []const u8) !void {
    const trimmed = std.mem.trim(u8, segment, " \n\r");
    if (startsWith(u8, trimmed, "#") or trimmed.len == 0) return;

    try self.list.append(self.gpa, try self.gpa.dupe(u8, trimmed));
}

pub fn fromFile(self: *Ignored, file: []const u8) !void {
    const f = if (fs.path.isAbsolute(file))
        try Io.Dir.openFileAbsolute(self.io, file, .{})
    else
        try Io.Dir.cwd().openFile(self.io, file, .{});
    defer f.close(self.io);

    var file_reader = f.reader(self.io, &.{});
    const reader = &file_reader.interface;

    var buf: [1024]u8 = undefined;
    var n = try reader.readSliceShort(&buf);

    while (n > 0) {
        var it = std.mem.splitScalar(u8, buf[0..n], '\n');
        while (it.next()) |line| {
            const trimmed = std.mem.trim(u8, line, " \n\r");
            if (startsWith(u8, trimmed, "#") or trimmed.len == 0) continue;

            try self.list.append(self.gpa, try self.gpa.dupe(u8, trimmed));
        }

        n = try reader.readSliceShort(&buf);
    }
}

pub fn isIgnored(self: *const Ignored, path: []const u8) bool {
    if (self.list.items.len == 0) return false;

    var it = fs.path.componentIterator(path);

    while (it.next()) |part| {
        for (self.list.items) |segment| {
            if (segment.len == 0) continue;

            switch (segment[0]) {
                '*' => {
                    var s = segment[1..];
                    if (segment[segment.len - 1] == '*') s = segment[1 .. segment.len - 1];

                    if (containsAtLeast(u8, part.path, 1, s)) return true;
                },
                else => {
                    const end = segment.len - 1;
                    if (segment[end] == '*' and startsWith(u8, part.name, segment[0..end])) return true;

                    if (eql(u8, part.name, segment)) return true;
                },
            }
        }
    }

    return false;
}
