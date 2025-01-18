const std = @import("std");
const math = std.math;
const testing = std.testing;


/// Cost and underlying matrix for calculation
const CostAndMatrix = struct {
  /// Dtw cost
  cost: f32,
  /// Dtw calculation matrix
  matrix: []f32,
  /// Length of the a side of the matrix
  matrixALen: usize,
  /// Length of the b side of the matrix
  matrixBLen: usize,
};


/// Calculate distance between values
fn distance(a: f32, b: f32) f32 {
  return @abs(a - b);
}


/// Convert a 2D index (a, b) to a 1D position
/// Used when storing a 2D array in a 1D array
pub fn index(amax: usize, bmax: usize, a: usize, b: usize) usize {
  _ = bmax;
  return (b * amax) + a;
}


/// Calculate cost difference between two sequences (dtw-style)
pub fn cost(allocator: std.mem.Allocator, a: []const f32, b: []const f32) !f32 {
  const result = costAndMatrix(allocator, a, b) catch |err| { return err; };
  defer allocator.free(result.matrix); // ?
  const c = result.cost;
  return c;
}


/// Calculate cost difference between two sequences (dtw-style)
/// Also return the underlying cost matrix (useful for debugging) 
pub fn costAndMatrix(allocator: std.mem.Allocator, a: []const f32, b: []const f32) !CostAndMatrix {
  // Init matrix
  const matrix_a_len :usize = a.len + 1;
  const matrix_b_len :usize = b.len + 1;

  var data = try allocator.alloc(f32, matrix_a_len * matrix_b_len);

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

  // Return final cost
  return .{
    .cost = data[a.len * matrix_b_len + b.len],
    .matrix = data,
    .matrixALen = matrix_a_len,
    .matrixBLen = matrix_b_len,
  };
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

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };

  const c = try cost(allocator, &a, &b);

  // epsilon to deal with float's lack of precision
  const epsilon = 1e-5;
  try testing.expect(@abs(c - 0) < epsilon);
}

test "cost - one difference" {
  const allocator = std.testing.allocator;

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 12, 14, 14, 14, 15, 17 };

  const c = try cost(allocator, &a, &b);

  // epsilon to deal with float's lack of precision
  const epsilon = 1e-5;
  try testing.expect(@abs(c - 1) < epsilon);
}

