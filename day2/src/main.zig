const std = @import("std");

/// The Main Function Fool
pub fn main() !void {
    // const fh = try std.fs.cwd().openIterableDir(".", .{});
    // var iterator = fh.iterate();
    // while (try iterator.next()) |path| {
    //     std.debug.print("{s}\n", .{path.name});
    // }
    // const fh = try std.fs.cwd().openFile("data/test.txt", .{});
    // defer fh.close();

    const data = [_]usize{ 1, 0, 0, 3, 1, 1, 2, 3, 1, 3, 4, 3, 1, 5, 0, 3, 2, 10, 1, 19, 1, 19, 9, 23, 1, 23, 13, 27, 1, 10, 27, 31, 2, 31, 13, 35, 1, 10, 35, 39, 2, 9, 39, 43, 2, 43, 9, 47, 1, 6, 47, 51, 1, 10, 51, 55, 2, 55, 13, 59, 1, 59, 10, 63, 2, 63, 13, 67, 2, 67, 9, 71, 1, 6, 71, 75, 2, 75, 9, 79, 1, 79, 5, 83, 2, 83, 13, 87, 1, 9, 87, 91, 1, 13, 91, 95, 1, 2, 95, 99, 1, 99, 6, 0, 99, 2, 14, 0, 0 };
    var prog: [data.len]usize = undefined;
    // _ = try fh.readAll(&data);
    // for (data[0..]) |c| {
    //     if (c != ',') {
    //         var v = try char_to_int(c);
    //         std.debug.print("Read {d} bytes\n", .{v});
    //     }
    // }
    // Restore Program state.
    for (data, 0..) |v, i| {
        prog[i] = v;
    }

    // RESTORE 1202 program state

    search: for (0..100) |i| {
        for (0..100) |j| {
            for (data, 0..) |v, k| {
                prog[k] = v;
            }
            prog[1] = i;
            prog[2] = j;

            run_program(&prog);

            if (prog[0] == 19690720) {
                std.debug.print("Value is {d}\n", .{100 * i + j});
                break :search;
            }
        }
    }
}

// Opcodes, Input, Input, Output
//
// 1: Addition
// 2: Multiplication
// _: Terminate
fn run_program(prog: []usize) void {
    const line_size = 4;
    var lno: usize = 0;

    while (true) {
        const line = prog[lno..][0..line_size];

        const opcode = line[0];

        switch (opcode) {
            1 => {
                const a = prog[line[1]];
                const b = prog[line[2]];
                const out = line[3];
                prog[out] = a + b;
            },
            2 => {
                const a = prog[line[1]];
                const b = prog[line[2]];
                const out = line[3];
                prog[out] = a * b;
            },
            else => return,
        }

        lno += line_size;
    }
}

fn char_to_int(c: u8) !u8 {
    if (c > 57) {
        return error.InvalidInput;
    } else if (c < 48) {
        return error.InvalidInput;
    }
    return c - 48;
}

test "simple test" {
    try std.testing.expectEqual(@as(u8, 1), try char_to_int('1'));
}
