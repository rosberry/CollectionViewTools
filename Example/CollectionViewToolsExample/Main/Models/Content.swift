//
//  Content.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

class Content {
    let id: Int
    let description: String

    init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
}

extension Content: Equatable {
    static func == (lhs: Content, rhs: Content) -> Bool {
        lhs.id == rhs.id
    }
}
