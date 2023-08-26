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
    )).?;
    std.debug.print("Distance is {d}\n", .{try coord.dist_manhattan()});
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
) !?Coord {
    var dist: isize = std.math.maxInt(isize);
    var coord: ?Coord = null;
    for (wire1.items) |a| {
        for (wire2.items) |b| {
            if (a.intersects(&b)) {
                const c = if (a.start.x == a.end.x) Coord{ .x = a.start.x, .y = b.start.y } else Coord{ .x = b.start.x, .y = a.start.y };
                const d = try c.dist_manhattan();
                if (d < dist and d != 0) {
                    std.debug.print("Found closser intersection between {?}, {?}\n", .{ a, b });
                    std.debug.print("New int is {?}\n", .{c});
                    coord = c;
                    dist = d;
                }
            }
        }
    }
    return coord;
}
