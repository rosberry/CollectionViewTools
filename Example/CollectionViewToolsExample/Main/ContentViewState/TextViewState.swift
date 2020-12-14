//
//  TextViewState.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class TextViewState: ContentViewState {
    var textContent: TextContent

    init(textContent: TextContent) {
        self.textContent = textContent
        super.init(content: textContent)
    }
}
