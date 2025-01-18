const std = @import("std");
const dtw = @import("dtw");

/// main
pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  const stdout = std.io.getStdOut().writer();

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 15, 16, 13, 14, 15, 18 };

  ////////////
  // Just cost
  const c = try dtw.cost(allocator, &a, &b);
  try stdout.print("cost: {d}\n", .{c});

  //////////////////
  // Cost and Matrix

  // Cost matrix
  const cm = try dtw.costAndMatrix(allocator, &a, &b); // catch |err| { stdout.print("ERROR: {}\n", .{err}); return; };
  defer allocator.free(cm.matrix); // ?
  
  try stdout.print("\n", .{});
  for (0..cm.matrixALen) |ai| {
    for (0..cm.matrixBLen) |bi| {
      if (ai == 0 or bi == 0) {
        try stdout.print("  -  ", .{});
      } else {
        try stdout.print("{d:5.1} ", .{ cm.matrix[dtw.index(cm.matrixALen, cm.matrixBLen, ai, bi)] });
      }
    }
    try stdout.print("\n", .{});
  }

  // Cost
  try stdout.print("cost: {d}\n", .{cm.cost});
}

