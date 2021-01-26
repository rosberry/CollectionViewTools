//
//  Copyright © 2019 Rosberry. All rights reserved.
//

/// Base object for `CollectionViewDelete` and `CollectionViewInsert`.
public class CollectionViewDeleteInsertBase<T>: CustomStringConvertible {

    /// Deleted/inserted item.
    let item: T

    /// Index of item.
    let index: Int

    public init(item: T, index: Int) {
        self.item = item
        self.index = index
    }

    public var description: String {
        return "\(index)"
    }
}

/// Use this object to describe insertion when you create your own `CollectionViewDiffAdaptor`.
public final class CollectionViewInsert<T>: CollectionViewDeleteInsertBase<T> {
}

/// Use this object to describe deletion when you create your own `CollectionViewDiffAdaptor`.
public final class CollectionViewDelete<T>: CollectionViewDeleteInsertBase<T> {
}

/// Use this object to describe update when you create your own `CollectionViewDiffAdaptor`.
public final class CollectionViewUpdate<T>: Hashable, CustomStringConvertible {

    /// Item before update.
    let oldItem: T

    /// New item.
    let newItem: T

    /// Index of item.
    let index: Int

    public init(oldItem: T, newItem: T, index: Int) {
        self.oldItem = oldItem
        self.newItem = newItem
        self.index = index
    }

    public var description: String {
        return "\(index)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: CollectionViewUpdate<T>, rhs: CollectionViewUpdate<T>) -> Bool {
        return lhs.index == rhs.index
    }
}

/// Use this object to describe move when you create your own `CollectionViewDiffAdaptor`.
public final class CollectionViewMove<T>: CustomStringConvertible, Equatable {

    /// Moving item.
    var item: T

    /// Index of item before moving.
    var from: Int

    /// Index of item after moving.
    let to: Int

    public init(item: T, from: Int, to: Int) {
        self.item = item
        self.from = from
        self.to = to
    }

    public var description: String {
        return "from \(from) to \(to)"
    }

    public static func == (lhs: CollectionViewMove<T>, rhs: CollectionViewMove<T>) -> Bool {
        return lhs.from == rhs.from &&
                lhs.to == rhs.to
    }
}

/// Use this object to describe change in CollectionView.
public final class CollectionViewChange<T>: CustomStringConvertible {

    /// Optional insertion.
    public var insert: CollectionViewInsert<T>?

    /// Optional deletion.
    public var delete: CollectionViewDelete<T>?

    /// Optional update.
    public var update: CollectionViewUpdate<T>?

    /// Optional move.
    public var move: CollectionViewMove<T>?

    public init(insert: CollectionViewInsert<T>? = nil,
                delete: CollectionViewDelete<T>? = nil,
                update: CollectionViewUpdate<T>? = nil,
                move: CollectionViewMove<T>? = nil) {
        self.insert = insert
        self.delete = delete
        self.update = update
        self.move = move
    }

    public var description: String {
        var strings: [String] = []
        if let insert = insert {
            strings.append("insert \(insert)")
        }
        else if let delete = delete {
            strings.append("delete \(delete)")
        }
        else if let update = update {
            strings.append("update \(update)")
        }
        else if let move = move {
            strings.append("move \(move)")
        }
        return strings.isEmpty ? "no changes" : strings.joined(separator: " ")
    }
}

final class CollectionViewChanges<T>: CustomStringConvertible {

    let inserts: [CollectionViewInsert<T>]
    let deletes: [CollectionViewDelete<T>]
    let updates: [CollectionViewUpdate<T>]
    let moves: [CollectionViewMove<T>]

    let insertedIndexes: [Int]
    let deletedIndexes: [Int]
    let updatedIndexes: [Int]

    let insertedItems: [T]
    let updatedItems: [T]

    let hasInserts: Bool
    let hasDeletes: Bool
    let hasUpdates: Bool
    let hasMoves: Bool

    init(changes: [CollectionViewChange<DiffItemWrapper>]) {
        var inserts: [CollectionViewInsert<T>] = []
        var deletes: [CollectionViewDelete<T>] = []
        var updates: [CollectionViewUpdate<T>] = []
        var moves: [CollectionViewMove<T>] = []

        var insertedIndexes: [Int] = []
        var deletedIndexes: [Int] = []
        var updatedIndexes: [Int] = []

        var insertedItems: [T] = []
        var updatedItems: [T] = []

        for change in changes {
            if let insert = change.insert,
                let item = insert.item.item as? T {
                inserts.append(CollectionViewInsert(item: item, index: insert.index))
                insertedIndexes.append(insert.index)
                insertedItems.append(item)
            }
            else if let delete = change.delete,
                let item = delete.item.item as? T {
                deletes.append(CollectionViewDelete(item: item, index: delete.index))
                deletedIndexes.append(delete.index)
            }
            else if let update = change.update,
                let oldItem = update.oldItem.item as? T,
                let newItem = update.newItem.item as? T {
                updates.append(CollectionViewUpdate(oldItem: oldItem, newItem: newItem, index: update.index))
                updatedIndexes.append(update.index)
                updatedItems.append(newItem)
            }
            else if let move = change.move,
                let item = move.item.item as? T {
                moves.append(CollectionViewMove(item: item, from: move.from, to: move.to))
            }
        }

        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves

        self.insertedIndexes = insertedIndexes
        self.deletedIndexes = deletedIndexes
        self.updatedIndexes = updatedIndexes

        self.insertedItems = insertedItems
        self.updatedItems = updatedItems

        self.hasInserts = inserts.count > 0
        self.hasDeletes = deletes.count > 0
        self.hasUpdates = updates.count > 0
        self.hasMoves = moves.count > 0
    }

    var description: String {
        var strings: [String] = []
        if inserts.count > 0 {
            strings.append("inserts = \(inserts)")
        }
        if deletes.count > 0 {
            strings.append("deletes = \(deletes)")
        }
        if updates.count > 0 {
            strings.append("updates = \(updates)")
        }
        if moves.count > 0 {
            strings.append("moves = \(moves)")
        }
        return strings.isEmpty ? "no changes" : strings.joined(separator: " ")
    }
}
