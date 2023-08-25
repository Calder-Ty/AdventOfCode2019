const std = @import("std");

const WireSegment = struct {
    dir: u8,
    magnitude: usize,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("data/in.test", .{});
    defer file.close();

    const input: []const u8 = try file.readToEndAlloc(allocator, 1024);
    std.debug.print("{s}", .{input});

    var splits = std.mem.splitScalar(u8, input, '\n');
    const first = try splits.next();
    //     const _second = splits.next();

    std.mem.tokenizeScalar([]u8, first, ',');
}
