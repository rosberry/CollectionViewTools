//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import DeepDiff

/// Adaptor that allows you to use DeepDiff with CollectionViewTools.
public final class CollectionViewDeepDiffAdaptor: CollectionViewDiffAdaptor {

    public init() {
    }

    public func changes<T: DiffItem>(old: [T], new: [T]) -> [CollectionViewChange<T>] {
        let oldWrappers = old.map { item in
            DeepDiffItemWrapper(item: item)
        }
        let newWrappers = new.map { item in
            DeepDiffItemWrapper(item: item)
        }
        let results = DeepDiff.diff(old: oldWrappers, new: newWrappers)
        let changes = results.map { result -> CollectionViewChange<T> in
            let change = CollectionViewChange<T>()
            if let insert = result.insert {
                change.insert = .init(item: insert.item.item, index: insert.index)
            }
            if let delete = result.delete {
                change.delete = .init(item: delete.item.item, index: delete.index)
            }
            if let replace = result.replace {
                change.update = .init(oldItem: replace.oldItem.item, newItem: replace.newItem.item, index: replace.index)
            }
            if let move = result.move {
                change.move = .init(item: move.item.item, from: move.fromIndex, to: move.toIndex)
            }
            return change
        }
        return changes
    }
}

final class DeepDiffItemWrapper<T: DiffItem>: DiffAware {

    public typealias DiffId = String

    let item: T

    init(item: T) {
        self.item = item
    }

    public var diffId: DiffId {
        return item.diffIdentifier
    }

    public static func compareContent(_ a: DeepDiffItemWrapper, _ b: DeepDiffItemWrapper) -> Bool {
        return a.item.isEqual(to: b.item)
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
