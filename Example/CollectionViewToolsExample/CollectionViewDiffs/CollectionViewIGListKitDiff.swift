//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import IGListKit
import CollectionViewTools

final class CollectionViewIGListKitDiff: CollectionViewDiff {

    func changes<T: CollectionViewDiffableItem>(old: [T], new: [T]) -> [CollectionViewChange<T>] {
        let oldWrappers = old.map { IGListKitDiffableItemWrapper(item: $0) }
        let newWrappers = new.map { IGListKitDiffableItemWrapper(item: $0) }
        let result = ListDiff(oldArray: oldWrappers, newArray: newWrappers, option: .equality)
        let inserts = result.inserts.map { index in
            CollectionViewChange(insertedItem: new[index],
                                 insertedIndex: index)
        }
        let deletes = result.deletes.map { index in
            CollectionViewChange(deletedItem: old[index],
                                 deletedIndex: index)
        }
        let updates = result.updates.map { index -> CollectionViewChange<T> in
            let oldItem = old[index]
            let newItem = new.first { $0.diffIdentifier == oldItem.diffIdentifier }
            return CollectionViewChange(replacedItem: newItem,
                                        oldReplacedItem: oldItem,
                                        replacedIndex: index)
        }
        let moves = result.moves.map { move in  
            CollectionViewChange(replacedItem: new[move.to],
                                 oldReplacedItem: old[move.from],
                                 replacedIndex: move.to)
        }
        return inserts + deletes + updates + moves
    }
}

public final class IGListKitDiffableItemWrapper<T: CollectionViewDiffableItem>: ListDiffable {

    let item: T

    init(item: T) {
        self.item = item
    }

    public func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: item.diffIdentifier)
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let wrapper = object as? IGListKitDiffableItemWrapper else {
            return false
        }
        return item.equal(to: wrapper.item)
    }
}
