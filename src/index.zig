//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const Allocator = std.mem.Allocator;

fn nextPowerOf2(x: usize) usize {
    if (x == 0) return 1;
    var result = x -% 1;
    result = switch (@sizeOf(usize)) {
        8 => result | (result >> 32),
        4 => result | (result >> 16),
        2 => result | (result >> 8),
        1 => result | (result >> 4),
        else => 0,
    };
    result |= (result >> 4);
    result |= (result >> 2);
    result |= (result >> 1);
    return result +% (1 + @boolToInt(x <= 0));
}

pub fn Trie(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            allocator: *Allocator,
            children: []?Node,
            data: ?T,

            fn new(allocator: *Allocator) Node {
                return Node {
                    .allocator = allocator,
                    .children = undefined,
                    .data = null,
                };
            }

            fn get(self: *Node, idx: usize) !*Node {
                if (idx > self.children.len) {
                    const new_size = nextPowerOf2(self.children.len + 1);
                    try self.allocator.realloc(Node, self.children, new_size);
                }
                return &self.children[idx];
            }

            fn getOrNull(self: Node, idx: usize) ?*const Node {
                if (idx > self.children.len) {
                    return null;
                }
                return &self.children[idx];
                return null;
            }
        };

        root: Node,

        pub fn init(allocator: *Allocator) Self {
            return Self {
                .root = Node.new(allocator),
            };
        }

        pub fn put(self: *Self, key: []const u8, value: T) !void {
            var node = &self.root;
            for (key) |c| {
                node = try node.get(@intCast(usize, c));
            }
            node.*.data = value;
        }

        pub fn get(self: Self, key: []const u8) ?T {
            var node = &self.root;
            for (key) |c| {
                node = node.getOrNull(@intCast(usize, c)) orelse {
                    return null;
                };
            }
            return node.*.data;
        }
    };
}

test "StaticTrie" {
    var trie = Trie([]const u8).init(std.debug.global_allocator);
    const words = [][]const u8 {
        "peter",   "piper",
        "picked",  "peck",
        "pickled", "peppers"
    };

    for (words) |word| {
        try trie.put(word, word);
    }

    for (words) |word| {
        std.debug.warn("{}\n", trie.get(word));
    }
}
