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
        print("<<< IG LIST KIT DIFF \(result)")
        let inserts = result.inserts.map { index in
            CollectionViewChange(insert: .init(item: new[index], index: index))
        }
        let deletes = result.deletes.map { index in
            CollectionViewChange(delete: .init(item: old[index], index: index))
        }
        let moves = result.moves.map { move in
            CollectionViewChange(move: CollectionViewMove(item: new[move.to],
                                                          from: move.from,
                                                          to: move.to))
        }
        let updates = result.updates.map { index -> CollectionViewChange<T> in
            let oldItem = old[index]
            let newItem = new.first { $0.diffIdentifier == oldItem.diffIdentifier }
            return CollectionViewChange(update: CollectionViewUpdate(oldItem: oldItem,
                                                                     newItem: newItem,
                                                                     index: index))
        }
        let changes = inserts + deletes + updates + moves
        return changes
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
        guard let wrapper = object as? IGListKitDiffableItemWrapper<T> else {
            return false
        }
        return item.equal(to: wrapper.item)
    }
}

extension ListMoveIndex {

    open override var description: String {
        return "from \(from) to \(to)"
    }
}

extension ListIndexSetResult {

    open override var description: String {
        var strings: [String] = []
        if inserts.count > 0 {
            strings.append("inserts = \(Array(inserts))")
        }
        if deletes.count > 0 {
            strings.append("deletes = \(Array(deletes))")
        }
        if updates.count > 0 {
            strings.append("updates = \(Array(updates))")
        }
        if moves.count > 0 {
            strings.append("moves = \(Array(moves))")
        }
        return strings.isEmpty ? "no changes" : strings.joined(separator: ", ")
    }
}
