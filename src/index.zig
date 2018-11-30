//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const mem = std.mem;
const Compare = mem.Compare;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

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
            prefix: ?[]const u8,
            children: []*Node,
            data: ?T,

            fn new(allocator: *Allocator, prefix: ?[]const u8) Node {
                return Node {
                    .allocator = allocator,
                    .children = undefined,
                    .prefix = prefix,
                    .data = null,
                };
            }

            fn add(self: *Node, node: *Node) !void {
                const new_size = self.children.len + 1;
                self.children = try self.allocator.realloc(*Node, self.children, new_size);
                self.children[new_size - 1] = node;
            }
        };

        nodes: ArrayList(Node),
        root: Node,

        pub fn init(allocator: *Allocator) Self {
            return Self {
                .nodes = ArrayList(Node).init(allocator),
                .root = Node.new(allocator, null),
            };
        }

        pub fn insert(self: *Self, key: []const u8, value: T) !void {
            var nodes = &self.root.children;
            // Compare.GreaterThan -- create new node, append node
            // Compare.Equal -- do nothing? (update value)
            // Compare.LessThan -- split node
        }

        pub fn get(self: Self, key: []const u8) ?T {
            return null;
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
