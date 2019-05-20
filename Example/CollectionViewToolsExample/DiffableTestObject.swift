//
//  DiffableTestObject.swift
//  CollectionViewToolsExample
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class DiffableTestObject: CollectionViewDiffableItem {

    var diffIdentifier: String
    var value: String

    init(id: Int, value: String) {
        diffIdentifier = "\(id)"
        self.value = value
    }

    func equal(to item: CollectionViewDiffableItem) -> Bool {
        guard let item = item as? DiffableTestObject else {
            return false
        }
        return value == item.value
    }
}
