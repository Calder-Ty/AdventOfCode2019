const std = @import("std");

const BASE_10 = 10;

const Direction = enum(u8) {
    up = 'U',
    down = 'D',
    left = 'L',
    right = 'R',
};

const WireSegment = struct {
    start: Coord,
    end: Coord,

    pub fn add(self: WireSegment, other: WireSegment) WireSegment {
        return WireSegment{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

const Coord = struct {
    x: isize,
    y: isize,

    pub fn add(self: Coord, other: Coord) Coord {
        return Coord{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("data/in.test", .{});
    defer file.close();

    const input: []const u8 = try file.readToEndAlloc(allocator, 2048);
    std.debug.print("{s}", .{input});

    var splits = std.mem.splitScalar(u8, input, '\n');
    const first = splits.next().?;
    const second = splits.next().?;

    const wire1 = try make_wire_segment(first, &allocator);
    _ = wire1;

    const wire2 = try make_wire_segment(second, &allocator);
    _ = wire2;
}

fn make_wire_segment(in: []const u8, allocator: *const std.mem.Allocator) !std.ArrayList(WireSegment) {
    var data = std.mem.tokenizeScalar(u8, in, ',');

    var wire1 = std.ArrayList(WireSegment).init(allocator.*);
    var start = Coord{ .x = 0, .y = 0 };
    var end: Coord = undefined;

    while (data.next()) |v| {
        const dir: Direction = @enumFromInt(v[0]);
        const magnitude: isize = try std.fmt.parseInt(isize, v[1..], BASE_10);
        end = switch (dir) {
            Direction.right => start.add(Coord{ .x = magnitude, .y = 0 }),
            Direction.left => start.add(Coord{ .x = -magnitude, .y = 0 }),

            Direction.up => start.add(Coord{ .x = 0, .y = magnitude }),
            Direction.down => start.add(Coord{ .x = 0, .y = -magnitude }),
        };
        try wire1.append(WireSegment{ .start = start, .end = end });
        start = end;
    }
    return wire1;
}

fn find_intersections(wire1: std.ArrayList(WireSegment), wire2: std.ArrayList(WireSegment)) void {
    _ = wire2;
    var start = Coord{ 0, 0 };
    _ = start;
    // Intersection is if: x1,
    for (wire1.items()) |segment| {
        _ = segment;
    }
}
