# DTW

Dynamic Time Warping

# Components

* Modules
  * dtw
* Example usage
  * example

# Development

```
# Build
zig build

# Run
zig build run

# Test
zig build test
zig test src/dtw.zig
```

# Usage

## Install
```
zig fetch --save git+https://github.com/0x6a62/dtw.git
```

## Add to your `build.zig`
```
const dtw = b.dependency("dtw", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("dtw", dtw.module("dtw"));
```

## Using in code
```
const dtw = @import("dtw");
```

