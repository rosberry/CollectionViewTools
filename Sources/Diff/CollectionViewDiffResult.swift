//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public final class CollectionViewDeleteInsert<T>: CustomStringConvertible {

    let item: T
    let index: Int

    public init(item: T, index: Int) {
        self.item = item
        self.index = index
    }

    public convenience init?(item: T?, index: Int?) {
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

public final class CollectionViewUpdate<T>: Hashable, CustomStringConvertible {

    let oldItem: T
    let newItem: T
    let index: Int

    public init(oldItem: T, newItem: T, index: Int) {
        self.oldItem = oldItem
        self.newItem = newItem
        self.index = index
    }

    public convenience init?(oldItem: T?, newItem: T?, index: Int?) {
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: CollectionViewUpdate<T>, rhs: CollectionViewUpdate<T>) -> Bool {
        return lhs.index == rhs.index
    }
}

public final class CollectionViewMove<T>: CustomStringConvertible, Equatable {

    var item: T
    var from: Int
    let to: Int

    public init(item: T, from: Int, to: Int) {
        self.item = item
        self.from = from
        self.to = to
    }

    public convenience init?(item: T?, from: Int?, to: Int?) {
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

public final class CollectionViewChange<T>: CustomStringConvertible {

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

    let hasInserts: Bool
    let hasDeletes: Bool
    let hasUpdates: Bool
    let hasMoves: Bool

    init(changes: [CollectionViewChange<CollectionViewDiffableItemWrapper>]) {
        var inserts: [CollectionViewDeleteInsert<T>] = []
        var insertedIndexes: [Int] = []
        var deletes: [CollectionViewDeleteInsert<T>] = []
        var deletedIndexes: [Int] = []
        var updates: [CollectionViewUpdate<T>] = []
        var updatedIndexes: [Int] = []
        var moves: [CollectionViewMove<T>] = []

        for change in changes {
            if let insert = change.insert,
                let item = insert.item.item as? T {
                inserts.append(CollectionViewDeleteInsert(item: item, index: insert.index))
                insertedIndexes.append(insert.index)
            }
            else if let delete = change.delete,
                let item = delete.item.item as? T {
                deletes.append(CollectionViewDeleteInsert(item: item, index: delete.index))
                deletedIndexes.append(delete.index)
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

        self.inserts = inserts
        self.deletes = deletes
        self.updates = updates
        self.moves = moves

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

final class CollectionViewDiffResult {

    typealias SectionChanges = CollectionViewChanges<CollectionViewDiffableSectionItem>
    typealias SectionUpdate = CollectionViewUpdate<CollectionViewDiffableSectionItem>
    typealias CellChanges = CollectionViewChanges<CollectionViewDiffableCellItem>
    typealias CellChangesMap = [SectionUpdate: CellChanges]

    let sectionChanges: SectionChanges
    let cellChangesMap: CellChangesMap

    let sectionUpdates: [SectionUpdate]
    let cellUpdatesMap: CellChangesMap
    let cellDeletesInsertsMovesMap: CellChangesMap

    let hasSectionUpdates: Bool
    let hasCellUpdates: Bool
    let hasCellDeletesInsertsMoves: Bool

    init(sectionChanges: SectionChanges, cellChangesMap: CellChangesMap) {
        self.sectionChanges = sectionChanges
        self.cellChangesMap = cellChangesMap

        var sectionUpdates: [SectionUpdate] = []
        var cellUpdatesMap: CellChangesMap = [:]
        var cellDeletesInsertsMovesMap: CellChangesMap = [:]

        for update in sectionChanges.updates {
            if let cellChanges = cellChangesMap[update] {
                if cellChanges.hasDeletes ||
                    cellChanges.hasInserts ||
                    cellChanges.hasMoves {
                    cellDeletesInsertsMovesMap[update] = cellChanges
                }
                if cellChanges.hasUpdates {
                    cellUpdatesMap[update] = cellChanges
                }
            }
            else {
                sectionUpdates.append(update)
            }
        }

        self.sectionUpdates = sectionUpdates
        self.cellUpdatesMap = cellUpdatesMap
        self.cellDeletesInsertsMovesMap = cellDeletesInsertsMovesMap

        hasSectionUpdates = sectionUpdates.count > 0
        self.hasCellUpdates = cellUpdatesMap.count > 0
        self.hasCellDeletesInsertsMoves = cellDeletesInsertsMovesMap.count > 0
    }
}