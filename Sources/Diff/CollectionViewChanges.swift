//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public struct CollectionViewDeleteInsert<T>: CustomStringConvertible {

    let item: T
    let index: Int

    public init(item: T, index: Int) {
        self.item = item
        self.index = index
    }

    public init?(item: T?, index: Int?) {
        if let item = item,
            let index = index {
            self.init(item: item, index: index)
        }
        else {
            return nil
        }
    }

    public var description: String {
        return "\(index)"
    }
}

public struct CollectionViewUpdate<T>: CustomStringConvertible {

    let oldItem: T
    let newItem: T
    let index: Int

    public init(oldItem: T, newItem: T, index: Int) {
        self.oldItem = oldItem
        self.newItem = newItem
        self.index = index
    }

    public init?(oldItem: T?, newItem: T?, index: Int?) {
        if let oldItem = oldItem,
            let newItem = newItem,
            let index = index {
            self.init(oldItem: oldItem, newItem: newItem, index: index)
        }
        else {
            return nil
        }
    }

    public var description: String {
        return "\(index)"
    }
}

public struct CollectionViewMove<T>: CustomStringConvertible, Equatable {

    let item: T
    let from: Int
    let to: Int

    public init(item: T, from: Int, to: Int) {
        self.item = item
        self.from = from
        self.to = to
    }

    public init?(item: T?, from: Int?, to: Int?) {
        if let item = item,
            let from = from,
            let to = to {
            self.init(item: item, from: from, to: to)
        }
        else {
            return nil
        }
    }

    public var description: String {
        return "from \(from) to \(to)"
    }

    public static func == (lhs: CollectionViewMove<T>, rhs: CollectionViewMove<T>) -> Bool {
        return lhs.from == rhs.from
            && lhs.to == rhs.to
    }
}

public struct CollectionViewChange<T>: CustomStringConvertible {

    let insert: CollectionViewDeleteInsert<T>?
    let delete: CollectionViewDeleteInsert<T>?
    let update: CollectionViewUpdate<T>?
    let move: CollectionViewMove<T>?

    public init(insert: CollectionViewDeleteInsert<T>? = nil,
                delete: CollectionViewDeleteInsert<T>? = nil,
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

    let inserts: [CollectionViewDeleteInsert<T>]
    let deletes: [CollectionViewDeleteInsert<T>]
    let updates: [CollectionViewUpdate<T>]
    let moves: [CollectionViewMove<T>]

    init(changes: [CollectionViewChange<CollectionViewDiffableItemWrapper>]) {
        var inserts: [CollectionViewDeleteInsert<T>] = []
        var deletes: [CollectionViewDeleteInsert<T>] = []
        var updates: [CollectionViewUpdate<T>] = []
        var updatedIndexes: [Int] = []
        var moves: [CollectionViewMove<T>] = []

        for change in changes {
            if let insert = change.insert,
                let item = insert.item.item as? T {
                inserts.append(CollectionViewDeleteInsert(item: item, index: insert.index))
            }
            else if let delete = change.delete,
                let item = delete.item.item as? T {
                deletes.append(CollectionViewDeleteInsert(item: item, index: delete.index))
            }
            else if let update = change.update,
                let oldItem = update.oldItem.item as? T,
                let newItem = update.newItem.item as? T {
                updates.append(CollectionViewUpdate(oldItem: oldItem, newItem: newItem, index: update.index))
                updatedIndexes.append(update.index)
            }
            else if let move = change.move,
                let item = move.item.item as? T {
                moves.append(CollectionViewMove(item: item, from: move.from, to: move.to))
            }
        }

        var filteredMoves = moves
        for move in moves {
            if let updatedIndex = updatedIndexes.firstIndex(of: move.from) {
                if let index = filteredMoves.firstIndex(of: move) {
                    filteredMoves.remove(at: index)
                }
                updates.remove(at: updatedIndex)
                updatedIndexes.remove(at: updatedIndex)
                deletes.append(CollectionViewDeleteInsert(item: move.item, index: move.from))
                inserts.append(CollectionViewDeleteInsert(item: move.item, index: move.to))
            }
        }

        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = filteredMoves
    }

    // MARK: - CustomStringConvertible

    var description: String {
        let strings = [
            inserts.count > 0 ? "inserts \(inserts)" : "",
            deletes.count > 0 ? "deletes \(deletes)" : "",
            updates.count > 0 ? "updates \(updates)" : "",
            moves.count > 0 ? "moves \(moves)" : "",
        ]
        return strings.isEmpty ? "no changes" : strings.joined(separator: " ")
    }
}
