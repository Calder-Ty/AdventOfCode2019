const std = @import("std");

const RANGE_START = 171309;
const RANGE_END = 643603;
// const RANGE_START = 111122;
// const RANGE_END = 111123;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var text_buf: [6]u8 = undefined;
    var count: usize = 0;
    for (RANGE_START..RANGE_END + 1) |x| {
        const text = try std.fmt.bufPrint(&text_buf, "{d}", .{x});
        if (try check_rules(text)) {
            count += 1;
        }
    }
    std.debug.print("Possible passwords: {d}\n", .{count});
}

pub fn check_rules(pass: []u8) !bool {
    var inc = true;
    var counts = [10]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var i: usize = 0;
    while (i <= 5) : (i += 1) {
        counts[(try std.fmt.charToDigit(pass[i], 10))] += 1;
        if (i < 5 and try std.fmt.charToDigit(pass[i + 1], 10) < try std.fmt.charToDigit(pass[i], 10)) {
            inc = false;
        }
    }
    var just_enough = false;
    for (counts) |x| {
        if (x == 2) {
            just_enough = true;
            break;
        }
    }

    //     std.debug.print("{any}\n", .{counts});
    //     std.debug.print("{?}, {?}\n", .{
    //         inc,
    //         just_enough,
    //     });

    return (inc and just_enough);
}
