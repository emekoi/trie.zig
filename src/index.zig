//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");

pub fn Trie(comptime T: type, comptime alphabet: comptime_int) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            children: [alphabet]?Node,
            data: ?T
        };

        root: Node,

        pub fn init() Self {
            return Self {
                .root = Node {
                    .data = null,
                    .children = []?Node { null } ** alphabet,
                },
            };
        }
    };
}

test "Trie" {
    comptime {
        var trie = Trie(u8, 26);
    }
}
