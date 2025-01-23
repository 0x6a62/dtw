const std = @import("std");
const math = std.math;
const testing = std.testing;

/// Calculate distance between values
fn distance(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .float => @abs(a - b),
        .int => {
            // Int doesn't seem to play well with @abs, signed vs unsighed
            if (a > b) {
                return a - b;
            } else {
                return b - a;
            }
        },
        else => @compileError("Unsupported type"),
    };
}

/// Convert a 2D index (a, b) to a 1D position
/// Used when storing a 2D array in a 1D array
pub fn index(amax: usize, a: usize, b: usize) usize {
    return (b * amax) + a;
}

/// Calculate cost difference between two sequences (dtw-style)
pub fn cost(comptime T: type, allocator: std.mem.Allocator, a: []const T, b: []const T) !T {
    const result = costAndMatrix(T, allocator, a, b) catch |err| {
        return err;
    };
    defer allocator.free(result.matrix); // ?
    const c = result.cost;
    return c;
}

/// Calculate cost difference between two sequences (dtw-style)
/// Also return the underlying cost matrix (useful for debugging)
pub fn costAndMatrix(comptime T: type, allocator: std.mem.Allocator, a: []const T, b: []const T) !struct {
    cost: T,
    matrix: []T,
    aLen: usize,
    bLen: usize,
} {
    // Init matrix
    const a_len: usize = a.len;
    const b_len: usize = b.len;

    var data = try allocator.alloc(T, a_len * b_len);

    // Calculate cost matrix
    for (0..a_len) |ai| {
        for (0..b_len) |bi| {
            const cell_cost = distance(T, a[ai], b[bi]);

            // previous cost is min of adjacent positions in matrix
            // Check for edge of matrix to stay in bounds
            const previous_cost =
                if (ai > 0 and bi > 0)
                @min(@min(data[index(a_len, ai - 1, bi)], data[index(a_len, ai, bi - 1)]), data[index(a_len, ai - 1, bi - 1)])
            else if (ai > 0)
                data[index(a_len, ai - 1, bi)]
            else if (bi > 0)
                data[index(a_len, ai, bi - 1)]
            else
                0;

            data[index(a_len, ai, bi)] = cell_cost + previous_cost;
        }
    }

    // Return final cost
    return .{
        .cost = data[index(a_len, a.len - 1, b.len - 1)],
        .matrix = data,
        .aLen = a_len,
        .bLen = b_len,
    };
}

/// Show cost matrix
/// Simple output of cost matrix (for debugging purposes)
pub fn showMatrix(comptime T: type, stdout: std.fs.File.Writer, aMax: usize, bMax: usize, matrix: []const T) !void {
    for (0..aMax) |ai| {
        for (0..bMax) |bi| {
            try stdout.print("{d:5.1} ", .{matrix[index(aMax, ai, bi)]});
        }
        try stdout.print("\n", .{});
    }
}

////////
// Tests

test "distance" {
    try testing.expect(distance(f32, 3.1, 9.2) == 6.1);
    try testing.expect(distance(f32, 9.2, 3.1) == 6.1);
    try testing.expect(distance(f32, 0, 0) == 0);
    try testing.expect(distance(f32, 8, 8) == 0);
}

test "cost - zero difference" {
    const allocator = std.testing.allocator;

    const a = [_]f32{ 10, 12, 13, 14, 14, 15, 17 };
    const b = [_]f32{ 10, 12, 13, 14, 14, 15, 17 };

    const c = try cost(f32, allocator, &a, &b);

    // epsilon to deal with float's lack of precision
    const epsilon = 1e-5;
    try testing.expect(@abs(c - 0) < epsilon);
}

test "cost - one difference" {
    const allocator = std.testing.allocator;

    const a = [_]f32{ 10, 12, 13, 14, 14, 15, 17 };
    const b = [_]f32{ 10, 12, 14, 14, 14, 15, 17 };

    const c = try cost(f32, allocator, &a, &b);

    // epsilon to deal with float's lack of precision
    const epsilon = 1e-5;
    try testing.expect(@abs(c - 1) < epsilon);
}
