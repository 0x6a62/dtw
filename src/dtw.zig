const std = @import("std");
const math = std.math;
const testing = std.testing;

/// Calculate distance between values
fn distance(a: f32, b: f32) f32 {
  return @abs(a - b);
}

/// Convert a 2D index (a, b) to a 1D position
/// Used when storing a 2D array in a 1D array
fn index(amax: usize, bmax: usize, a: usize, b: usize) usize {
  _ = bmax;
  return (b * amax) + a;
}

/// Calculate cost difference between two sequences (dtw-style)
pub fn cost(allocator: std.mem.Allocator, stdout: std.fs.File.Writer, debug: bool, a: []const f32, b: []const f32) !f32 {
  // Init matrix
  const matrix_a_len :usize = a.len + 1;
  const matrix_b_len :usize = b.len + 1;

  var data = try allocator.alloc(f32, matrix_a_len * matrix_b_len);
  defer allocator.free(data);

  // Init edges to max value, since they should never be considered in the cost path calculation
  for (1..matrix_a_len) |ai| {
    data[index(matrix_a_len, matrix_b_len, ai, 0)] = math.floatMax(f32);
  }
  for (1..matrix_b_len) |bi| {
    data[index(matrix_a_len, matrix_b_len, 0, bi)] = math.floatMax(f32);
  }

  // Calculate cost matrix
  // NOTE: ai and bi represent index in data (do -1 when referencing into the a and b arrays)
  for (1..matrix_a_len) |ai| {
    for (1..matrix_b_len) |bi| {
      const cell_cost = distance(a[ai - 1], b[bi - 1]);
      data[index(matrix_a_len, matrix_b_len, ai, bi)] =
        cell_cost +
        @min(
          @min(
            data[index(matrix_a_len, matrix_b_len, ai - 1, bi)],
            data[index(matrix_a_len, matrix_b_len, ai, bi - 1)]),
            data[index(matrix_a_len, matrix_b_len, ai - 1, bi - 1)]);
    }
  }

  // Dump cost matrix
  if (debug) {
    try stdout.print("\n", .{});
    for (0..matrix_a_len) |ai| {
      for (0..matrix_b_len) |bi| {
        if (ai == 0 or bi == 0) {
          try stdout.print("  -  ", .{});
        } else {
          try stdout.print("{d:5.1} ", .{ data[index(matrix_a_len, matrix_b_len, ai, bi)] });
        }
      }
      try stdout.print("\n", .{});
    }
  }

  // Return final cost
  return data[a.len * matrix_b_len + b.len];
}


////////
// Tests


test "distance" {
  try testing.expect(distance(3.1, 9.2) == 6.1);
  try testing.expect(distance(9.2, 3.1) == 6.1);
  try testing.expect(distance(0, 0) == 0);
  try testing.expect(distance(8, 8) == 0);
}

test "cost - zero difference" {
  const allocator = std.testing.allocator;
  const stdout = std.io.getStdOut().writer();

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };

  const c = try cost(allocator, stdout, false, &a, &b);

  // epsilon to deal with float's lack of precision
  const epsilon = 1e-5;
  try testing.expect(@abs(c - 0) < epsilon);
}

test "cost - one difference" {
  const allocator = std.testing.allocator;
  const stdout = std.io.getStdOut().writer();

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 12, 14, 14, 14, 15, 17 };

  const c = try cost(allocator, stdout, false, &a, &b);

  // epsilon to deal with float's lack of precision
  const epsilon = 1e-5;
  try testing.expect(@abs(c - 1) < epsilon);
}

