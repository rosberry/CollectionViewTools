//
//  TextContent.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class TextContent: Content {
    let title: String

    init(id: Int, title: String, description: String) {
        self.title = title
        super.init(id: id, description: description)
    }
}
