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

    fn len(self: *const WireSegment) !isize {
        if (self.start.x != self.end.x) {
            return std.math.absInt(self.end.x - self.start.x);
        } else {
            return std.math.absInt(self.end.y - self.start.y);
        }
    }

    pub fn add(self: WireSegment, other: WireSegment) WireSegment {
        return WireSegment{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn intersects(self: *const WireSegment, other: *const WireSegment) bool {
        // Make sure we order the arguments right
        // left->rigth/Horizontal, bottom->top/Vertical
        return intersect_x_plane(self, other) and intersect_y_plane(self, other);
    }

    fn intersect_x_plane(self: *const WireSegment, other: *const WireSegment) bool {
        return ((self.*.start.x <= other.*.start.x and other.*.start.x <= self.*.end.x) or
            (self.*.start.x >= other.*.start.x and other.*.start.x >= self.*.end.x) or
            (other.*.start.x <= self.*.start.x and self.*.start.x <= other.*.end.x) or
            (other.*.start.x >= self.*.start.x and self.*.start.x >= other.*.end.x));
    }

    fn intersect_y_plane(self: *const WireSegment, other: *const WireSegment) bool {
        return ((self.*.start.y <= other.*.start.y and other.*.start.y <= self.*.end.y) or
            (self.*.start.y >= other.*.start.y and other.*.start.y >= self.*.end.y) or
            (other.*.start.y <= self.*.start.y and self.*.start.y <= other.*.end.y) or
            (other.*.start.y >= self.*.start.y and self.*.start.y >= other.*.end.y));
    }
};

const Coord = struct {
    x: isize,
    y: isize,

    const ORIGIN = Coord{ .x = 0, .y = 0 };

    pub fn add(self: Coord, other: Coord) Coord {
        return Coord{ .x = self.x + other.x, .y = self.y + other.y };
    }

    fn dist_manhattan(self: *const Coord) !isize {
        return (try std.math.absInt(self.x)) + (try std.math.absInt(self.y));
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("data/in.prod", .{});
    defer file.close();

    const input: []const u8 = try file.readToEndAlloc(allocator, 4096);

    var splits = std.mem.splitScalar(u8, input, '\n');
    const first = splits.next().?;
    const second = splits.next().?;

    const wire1 = try make_wire_segment(first, &allocator);
    const wire2 = try make_wire_segment(second, &allocator);

    const coord = (try find_nearest_intersection(
        wire1,
        wire2,
    ));
    std.debug.print("Distance is {d}\n", .{coord});
}

fn make_wire_segment(
    in: []const u8,
    allocator: *const std.mem.Allocator,
) !std.ArrayList(WireSegment) {
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

fn find_nearest_intersection(
    wire1: std.ArrayList(WireSegment),
    wire2: std.ArrayList(WireSegment),
) !isize {
    var dist: isize = std.math.maxInt(isize);
    var coord: ?Coord = null;
    var wire1_dist: isize = 0;
    for (wire1.items) |a| {
        var wire2_dist: isize = 0;
        for (wire2.items) |b| {
            if (a.intersects(&b)) {
                var c: Coord = undefined;
                var d: isize = undefined;
                if (a.start.x == a.end.x) {
                    c = Coord{ .x = a.start.x, .y = b.start.y };
                    d = wire1_dist + wire2_dist + try std.math.absInt(c.y - a.start.y) + try std.math.absInt(c.x - b.start.x);
                } else {
                    c = Coord{ .x = b.start.x, .y = a.start.y };
                    d = wire1_dist + wire2_dist + try std.math.absInt(c.y - b.start.y) + try std.math.absInt(c.x - a.start.x);
                }
                if (d < dist and d != 0) {
                    std.debug.print("Found closser intersection between {?}, {?}\n", .{ a, b });
                    std.debug.print("New int is {?}\n", .{c});
                    coord = c;
                    dist = d;
                }
            }
            wire2_dist += try b.len();
        }
        wire1_dist += try a.len();
    }
    return dist;
}
