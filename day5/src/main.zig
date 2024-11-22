const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var program = try loadProgram(allocator);
    std.mem.tokenizeScalar(
        u8,
        program,
    );
}

fn loadProgram(allocator: std.heap.Alloctator) ![]u8 {
    const fd = try std.fs.cwd().openFile("data/prod.txt", .{});
    return fd.readToEndAlloc(allocator, 1024 * 10);
}

// Yes we have to use usize, because we could get really large outputv alues
const Opcode = enum(usize) {
    add = 1,
    multiply = 2,
    input = 3,
    output = 4,
    halt = 99,
};

const ParameterMode = enum(u8) {
    position = 0,
    immediate = 1,
};

// run the program
fn runProgram(program: []isize) void {
    var ip = 0;
    main: while (true) {
        // NOTE: This will Panic if we get something that doesn't fit
        // we could use std.meta.intToEnum if we needed to catch the erro.
        // For now I'm ok with panicing
        const state: Opcode = @enumFromInt(program[ip]);
        switch (state) {
            .add => {
                program[program[ip + 3]] = program[program[ip + 1]] + program[program[ip + 2]];
                ip += 4;
            },
            .multiply => {
                program[program[ip + 3]] = program[program[ip + 1]] * program[program[ip + 2]];
                ip += 4;
            },
            .input => {
                //?///
            },
            .output => {
                //???
            },
            .halt => {
                break :main;
            },
        }
    }
}
