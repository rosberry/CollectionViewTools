//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import DeepDiff
import CollectionViewTools

final class CollectionViewDeepDiff: CollectionViewDiff {

    func changes<T: CollectionViewDiffableItem>(old: [T], new: [T]) -> [CollectionViewChange<T>] {
        let oldWrappers = old.map { DeepDiffDiffableItemWrapper(item: $0) }
        let newWrappers = new.map { DeepDiffDiffableItemWrapper(item: $0) }
        let changes = DeepDiff.diff(old: oldWrappers, new: newWrappers)
        return changes.map { change in
            CollectionViewChange(insertedItem: change.insert?.item.item,
                                 insertedIndex: change.insert?.index,
                                 deletedItem: change.delete?.item.item,
                                 deletedIndex: change.delete?.index,
                                 replacedItem: change.replace?.newItem.item,
                                 oldReplacedItem: change.replace?.oldItem.item,
                                 replacedIndex: change.replace?.index)
        }
    }
}

public final class DeepDiffDiffableItemWrapper<T: CollectionViewDiffableItem>: DiffAware {

    public typealias DiffId = String

    let item: T

    init(item: T) {
        self.item = item
    }

    public var diffId: DiffId {
        return item.diffIdentifier
    }

    public static func compareContent(_ a: DeepDiffDiffableItemWrapper, _ b: DeepDiffDiffableItemWrapper) -> Bool {
        return a.item.equal(to: b.item)
    }
}
