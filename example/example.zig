const std = @import("std");
const dtw = @import("dtw");

/// main
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const stdout = std.io.getStdOut().writer();

    //////
    // f32
    {
        try stdout.print("\nf32\n", .{});

        const a = [_]f32{ 10, 12, 13, 14, 14, 15, 17 };
        const b = [_]f32{ 10, 15, 16, 13, 14, 18, 20 };

        ////////////
        // Just cost
        const c = try dtw.cost(f32, allocator, &a, &b);
        try stdout.print("cost: {d}\n", .{c});

        //////////////////
        // Cost and Matrix
        const cm = try dtw.costAndMatrix(f32, allocator, &a, &b);
        defer allocator.free(cm.matrix); // ?

        try stdout.print("\n", .{});
        for (0..cm.matrixALen) |ai| {
            for (0..cm.matrixBLen) |bi| {
                if (ai == 0 or bi == 0) {
                    try stdout.print("  -  ", .{});
                } else {
                    try stdout.print("{d:5.1} ", .{cm.matrix[dtw.index(cm.matrixALen, cm.matrixBLen, ai, bi)]});
                }
            }
            try stdout.print("\n", .{});
        }
        // Cost
        try stdout.print("cost: {d}\n", .{cm.cost});
    }

    //////
    // f64
    {
        try stdout.print("\nf64\n", .{});

        const a = [_]f64{ 10, 12, 13, 14, 14, 15, 17 };
        const b = [_]f64{ 10, 15, 16, 13, 14, 15, 18 };

        ////////////
        // Just cost
        const c = try dtw.cost(f64, allocator, &a, &b);
        try stdout.print("cost: {d}\n", .{c});

        //////////////////
        // Cost and Matrix
        const cm = try dtw.costAndMatrix(f64, allocator, &a, &b);
        defer allocator.free(cm.matrix); // ?

        try stdout.print("\n", .{});
        for (0..cm.matrixALen) |ai| {
            for (0..cm.matrixBLen) |bi| {
                if (ai == 0 or bi == 0) {
                    try stdout.print("  -  ", .{});
                } else {
                    try stdout.print("{d:5.1} ", .{cm.matrix[dtw.index(cm.matrixALen, cm.matrixBLen, ai, bi)]});
                }
            }
            try stdout.print("\n", .{});
        }
        // Cost
        try stdout.print("cost: {d}\n", .{cm.cost});
    }

    //////
    // i64
    {
        try stdout.print("\ni64\n", .{});

        const a = [_]i64{ 10, 12, 13, 14, 14, 15, 17 };
        const b = [_]i64{ 20, 15, 16, 13, 14, 15, 18 };

        ////////////
        // Just cost
        const c = try dtw.cost(i64, allocator, &a, &b);
        try stdout.print("cost: {d}\n", .{c});

        //////////////////
        // Cost and Matrix
        const cm = try dtw.costAndMatrix(i64, allocator, &a, &b);
        defer allocator.free(cm.matrix); // ?

        try stdout.print("\n", .{});
        for (0..cm.matrixALen) |ai| {
            for (0..cm.matrixBLen) |bi| {
                if (ai == 0 or bi == 0) {
                    try stdout.print("  -  ", .{});
                } else {
                    try stdout.print("{d:4} ", .{cm.matrix[dtw.index(cm.matrixALen, cm.matrixBLen, ai, bi)]});
                }
            }
            try stdout.print("\n", .{});
        }
        // Cost
        try stdout.print("cost: {d}\n", .{cm.cost});
    }
}
