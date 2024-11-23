const std = @import("std");
const TokenIterator = std.mem.TokenIterator;
const Allocator = std.mem.Allocator;

const INPUT: isize = 5;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try loadProgram(allocator);
    var data_iter = std.mem.tokenizeScalar(u8, data[0 .. data.len - 1], ',');
    const program = try collect(allocator, &data_iter, data.len / 2);

    runProgram(program);
}

fn loadProgram(allocator: Allocator) ![]u8 {
    const fd = try std.fs.cwd().openFile("data/prod.txt", .{});
    return fd.readToEndAlloc(allocator, 1024 * 10);
}

fn collect(allocator: Allocator, iter: *TokenIterator(u8, .scalar), n: usize) ![]isize {
    var items = try std.ArrayList(isize).initCapacity(allocator, n);
    while (iter.next()) |item| {
        const v = try std.fmt.parseInt(isize, item, 10);
        try items.append(v);
    }
    return try items.toOwnedSlice();
}

// Yes we have to use usize, because we could get really large outputv alues
const Opcode = enum(usize) {
    add = 1,
    multiply = 2,
    input = 3,
    output = 4,
    jumpTrue = 5,
    jumpFalse = 6,
    lessThan = 7,
    equals = 8,
    halt = 99,
};

const ParameterMode = enum(u8) {
    position = 0,
    immediate = 1,
};

// run the program
fn runProgram(tape: []isize) void {
    var ip: usize = 0;
    main: while (true) {
        const opcode, const instruction = getInstruction(tape[ip]);
        switch (opcode) {
            .add => {
                const x, const y, const out = instruction.binary.getParams(tape, ip);
                tape[(out)] = x + y;
                ip += 4;
            },
            .multiply => {
                const x, const y, const out = instruction.binary.getParams(tape, ip);
                tape[(out)] = x * y;
                ip += 4;
            },
            .input => {
                tape[@intCast(tape[ip + 1])] = INPUT;
                ip += 2;
            },
            .output => {
                const x = if (instruction.io[0] == .position) tape[@intCast(tape[ip + 1])] else tape[ip + 1];
                std.debug.print("{d}\n", .{x});
                ip += 2;
            },
            .jumpTrue => {
                const x, const y, _ = instruction.binary.getParams(tape, ip);
                if (x != 0) {
                    ip = @intCast(y);
                } else {
                    ip += 3;
                }
            },
            .jumpFalse => {
                const x, const y, _ = instruction.binary.getParams(tape, ip);
                if (x == 0) {
                    ip = @intCast(y);
                } else {
                    ip += 3;
                }
            },
            .lessThan => {
                const x, const y, const out = instruction.binary.getParams(tape, ip);
                if (x < y) {
                    tape[out] = 1;
                } else {
                    tape[out] = 0;
                }
                ip += 4;
            },
            .equals => {
                const x, const y, const out = instruction.binary.getParams(tape, ip);
                if (x == y) {
                    tape[out] = 1;
                } else {
                    tape[(out)] = 0;
                }
                ip += 4;
            },
            .halt => {
                break :main;
            },
        }
    }
}

fn getInstruction(code: isize) struct { Opcode, Instruction } {
    const parameterModes = @divFloor(code, 100);
    const opcode: Opcode = @enumFromInt(code - parameterModes * 100);
    switch (opcode) {
        .add, .multiply, .equals, .lessThan, .jumpTrue, .jumpFalse => |op| {
            const param0: ParameterMode = @enumFromInt(@mod(parameterModes, 2));
            const param1: ParameterMode = @enumFromInt(@mod(@divFloor(parameterModes, 10), 2));
            return .{ op, Instruction{ .binary = .{ .x=param0, .y=param1, .out=.position } } };
        },
        .input => return .{ .input, Instruction{ .io = .{.position} } },
        .output => {
            return .{ .output, Instruction{ .io = .{@enumFromInt(@mod(parameterModes, 2))} } };
        },
        .halt => return .{ .halt, Instruction.halt },
    }
}

const Instruction = union(enum) {
    binary: Binary,
    io: IO,
    halt,
};

const Binary = struct { 
    x: ParameterMode, 
    y: ParameterMode, 
    out: ParameterMode,

    fn getParams(self: Binary, data: []isize, ip: usize) struct {isize, isize, usize} {
        const x = if (self.x == .position) data[@intCast(data[ip + 1])] else data[ip + 1];
        const y = if (self.y == .position) data[@intCast(data[ip + 2])] else data[ip + 2];
        const z: usize = @intCast(data[ip + 3]);
        return .{x, y, z};
    }
};

const IO = struct { ParameterMode};
