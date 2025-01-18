const std = @import("std");
const dtw = @import("dtw");

/// main
pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  const stdout = std.io.getStdOut().writer();

  const a = [_]f32 { 10, 12, 13, 14, 14, 15, 17 };
  const b = [_]f32 { 10, 15, 16, 13, 14, 15, 18 };

  const c = try dtw.cost(allocator, stdout, false, &a, &b);

  try stdout.print("cost: {d}\n", .{c});
}

