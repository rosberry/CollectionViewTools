//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import DeepDiff
import CollectionViewTools

final class CollectionViewDeepDiff: CollectionViewDiff {

    func changes<T: CollectionViewDiffableItem>(old: [T], new: [T]) -> [CollectionViewChange<T>] {
        let oldWrappers = old.map { DeepDiffDiffableItemWrapper(item: $0) }
        let newWrappers = new.map { DeepDiffDiffableItemWrapper(item: $0) }
        let results = DeepDiff.diff(old: oldWrappers, new: newWrappers)
        let changes = results.map { result -> CollectionViewChange<T> in
            return CollectionViewChange(insert: CollectionViewDeleteInsert(item: result.insert?.item.item,
                                                                           index: result.insert?.index),
                                        delete: CollectionViewDeleteInsert(item: result.delete?.item.item,
                                                                           index: result.delete?.index),
                                        update: CollectionViewUpdate(oldItem: result.replace?.oldItem.item,
                                                                     newItem: result.replace?.newItem.item,
                                                                     index: result.replace?.index),
                                        move: CollectionViewMove(item: result.move?.item.item,
                                                                 from: result.move?.fromIndex,
                                                                 to: result.move?.toIndex))
        }
        return changes
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

extension DeepDiff.Change: CustomStringConvertible {

    public var description: String {
        var strings: [String] = []
        if let insert = insert {
            strings.append("insert \(insert.index)")
        }
        if let delete = delete {
            strings.append("delete \(delete.index)")
        }
        if let replace = replace {
            strings.append("update \(replace.index)")
        }
        if let move = move {
            strings.append("move from \(move.fromIndex) to \(move.toIndex)")
        }
        return strings.isEmpty ? "no changes" : strings.joined(separator: " ")
    }
}
