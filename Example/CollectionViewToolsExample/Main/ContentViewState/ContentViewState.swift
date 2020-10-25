//
//  DataViewState.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

class ContentViewState {
    var isExpanded: Bool = false
    var content: Content

    init(content: Content) {
        self.content = content
    }
}

extension ContentViewState: GenericDiffItem {
    var diffIdentifier: String {
        "\(content.id)/\(content.description)"
    }

    func isEqual(to item: ContentViewState) -> Bool {
        isExpanded == item.isExpanded
    }
}
