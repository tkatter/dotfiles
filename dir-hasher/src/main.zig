const std = @import("std");
const Entry = @import("Entry.zig");
const Ignored = @import("Ignored.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const Blake3 = std.crypto.hash.Blake3;

fn print(io: Io, comptime fmt: []const u8, args: anytype) void {
    const f = Io.File.stdout();
    var f_writer = f.writer(io, &.{});
    const writer = &f_writer.interface;

    writer.print(fmt, args) catch {};
    writer.flush() catch {};
}

fn defaultDir(io: Io, alloc: Allocator) ![:0]u8 {
    return try std.process.currentPathAlloc(io, alloc);
}

fn openDir(io: Io, path: [:0]const u8) !Io.Dir {
    if (std.fs.path.isAbsolute(path)) {
        return try Io.Dir.openDirAbsolute(io, path, .{ .iterate = true });
    } else {
        return try Io.Dir.cwd().openDir(io, path, .{ .iterate = true });
    }
}

const usage =
    \\Usage: dir-hasher -d DIR -i IGNORE_FILE
    \\  -d, --dir DIR
    \\        The directory to recursively hash files in.
    \\  -i, --ignore-file IGNORE_FILE
    \\        File containing a list of segments/paths to ignore.
    \\        Each segment should be on a separate line.
;

const entry_fmt_string =
    \\{s}
    \\    Permissions: {o}, Size: {}
    \\    {s}
    \\
;

const FlagsSet = packed struct(u2) {
    dir: bool = false,
    ignore: bool = false,
};

pub fn main(init: std.process.Init) !void {
    const gpa: Allocator = init.gpa;
    const io = init.io;

    var path_to_hash: [:0]const u8 = try defaultDir(io, gpa);
    var ignore_segments: Ignored = .init(io, gpa);
    defer ignore_segments.deinit();

    var args = init.minimal.args.iterate();
    var flags: FlagsSet = .{};

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--dir")) {
            if (args.next()) |dir| {
                gpa.free(path_to_hash);
                path_to_hash = dir;
                flags.dir = true;
            }
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            std.debug.print(usage, .{});
            std.process.exit(1);
        } else if (std.mem.eql(u8, arg, "-i") or std.mem.eql(u8, arg, "--ignore")) {
            if (args.next()) |ignore| {
                try ignore_segments.addSegment(ignore);
                flags.ignore = true;
            }
        } else if (std.mem.eql(u8, arg, "-I") or std.mem.eql(u8, arg, "--ignore-file")) {
            if (args.next()) |ignore_file| {
                try ignore_segments.fromFile(ignore_file);
                flags.ignore = true;
            }
        }
    }

    if (!flags.ignore) try ignore_segments.default();

    const hash_dir: Io.Dir = try openDir(io, path_to_hash);
    defer hash_dir.close(io);

    // var walker = try hash_dir.walk(gpa);
    var walker = try hash_dir.walkSelectively(gpa);
    defer walker.deinit();

    var entries: std.ArrayList(Entry) = .empty;
    defer entries.deinit(gpa);
    defer for (entries.items) |e| e.deinit(gpa);

    while (try walker.next(io)) |entry| {
        switch (entry.kind) {
            .file => {
                if (ignore_segments.isIgnored(entry.path)) continue;

                const e: Entry = try .fromWalkerEntry(gpa, path_to_hash, &entry);
                _ = try entries.append(gpa, e);
            },
            .directory => {
                if (ignore_segments.isIgnored(entry.path)) continue;

                // XXX remove this comment to include normal directories in the output
                // const e: Entry = try .fromWalkerEntry(gpa, path_to_hash, &entry);
                // _ = try entries.append(gpa, e);

                try walker.enter(io, entry);
            },
            else => continue,
        }
    }

    const mid = entries.items.len / 2;
    // thanks ziglings
    {
        const t1 = try std.Thread.spawn(.{}, hashEntries, .{entries.items[0..mid]});
        defer t1.join();

        const t2 = try std.Thread.spawn(.{}, hashEntries, .{entries.items[mid..]});
        defer t2.join();
    }

    for (entries.items) |entry| {
        switch (entry.kind) {
            .file => {
                const f = if (std.fs.path.isAbsolute(entry.path))
                    try Io.Dir.openFileAbsolute(io, entry.path, .{ .path_only = true })
                else
                    try Io.Dir.cwd().openFile(io, entry.path, .{ .path_only = true });
                defer f.close(io);

                const stat = try f.stat(io);

                print(io, entry_fmt_string, .{
                    entry.path,
                    stat.permissions.toMode() & 0o777,
                    stat.size,
                    std.fmt.bytesToHex(entry.hash orelse @as([32]u8, @splat('-')), .lower),
                });
            },
            else => print(io, "{s}\n", .{entry.path}),
        }
    }

    if (!flags.dir) gpa.free(path_to_hash);
}

fn hashEntries(entries: []Entry) !void {
    var io_instance: std.Io.Threaded = .init_single_threaded;
    const io = io_instance.io();

    var blake3 = Blake3.init(.{});
    var buf: [4096]u8 = undefined;

    var i: usize = 0;
    while (i < entries.len) {
        try entries[i].doHash(io, &blake3, &buf);
        i += 1;
    }
}

// test "simple test" {
//     const gpa = std.testing.allocator;
//     var list: std.ArrayList(i32) = .empty;
//     defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(gpa, 42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
