//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

extension CollectionViewManager {

    public typealias DiffCompletion = (Bool) -> Void

    var diffableSectionItems: [CollectionViewDiffableSectionItem] {
        return sectionItems.compactMap { $0 as? CollectionViewDiffableSectionItem }
    }

    open func update(with sectionItems: [CollectionViewDiffableSectionItem],
                     diff: CollectionViewDiff,
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: DiffCompletion? = nil) {
        if animated {
            if self.sectionItems.isEmpty {
                updateEmptyCollectionView(with: sectionItems, completion: completion)
                return
            }

            calculateDiffResult(for: sectionItems, diff: diff) { diffResult in
                guard let diffResult = diffResult else {
                    return
                }
                self.updateCollectionView(with: sectionItems,
                                          diffResult: diffResult,
                                          ignoreCellItemsChanges: ignoreCellItemsChanges,
                                          completion: completion)
            }
        }
        else {
            update(sectionItems, shouldReloadData: true)
            completion?(true)
            return
        }
    }

    private func updateEmptyCollectionView(with sectionItems: [CollectionViewDiffableSectionItem], completion: DiffCompletion?) {
        if sectionItems.isEmpty {
            completion?(false)
            return
        }
        insert(sectionItems, at: Array(0..<sectionItems.count), performUpdates: true) { _ in
            completion?(true)
        }
        recalculateIndexes()
    }

    private func updateCollectionView(with sectionItems: [CollectionViewDiffableSectionItem],
                                      diffResult: CollectionViewDiffResult,
                                      ignoreCellItemsChanges: Bool,
                                      completion: DiffCompletion?) {
        var hasDeletesInsertsMoves: Bool?
        var hasUpdates: Bool?

        func complete() {
            if let hasDeletesInsertsMoves = hasDeletesInsertsMoves,
                let hasUpdates = hasUpdates {
                completion?(hasDeletesInsertsMoves || hasUpdates)
            }
        }

        deleteInsertMoveSectionItems(for: diffResult) { changed in
            hasDeletesInsertsMoves = changed
            complete()
        }

        updateSectionItems(for: diffResult, ignoreCellItemsChanges: ignoreCellItemsChanges) { changed in
            hasUpdates = changed
            complete()
        }

        update(sectionItems, shouldReloadData: false)
        recalculateIndexes()
    }

    // MARK: - Section Items

    private func deleteInsertMoveSectionItems(for diffResult: CollectionViewDiffResult, completion: DiffCompletion?) {
        guard diffResult.sectionChanges.hasDeletes ||
            diffResult.sectionChanges.hasInserts ||
            diffResult.sectionChanges.hasMoves else {
                completion?(false)
                return
        }
        collectionView.performBatchUpdates({
            deleteSectionItems(with: diffResult.sectionChanges.deletes)
            insertSectionItems(with: diffResult.sectionChanges.inserts)
            moveSectionItems(with: diffResult.sectionChanges.moves)
            recalculateIndexes()
        }, completion: { _ in
            completion?(true)
        })
    }

    private func updateSectionItems(for diffResult: CollectionViewDiffResult,
                                    ignoreCellItemsChanges: Bool,
                                    completion: DiffCompletion?) {
        guard diffResult.sectionChanges.hasUpdates else {
            completion?(false)
            return
        }

        if ignoreCellItemsChanges {
            updateSectionItems(with: diffResult.sectionChanges.updates)
            completion?(true)
        }
        else {
            var hasDeletesInsertsMoves: Bool?
            var hasUpdates: Bool?

            func complete() {
                if let hasDeletesInsertsMoves = hasDeletesInsertsMoves,
                    let hasUpdates = hasUpdates {
                    completion?(hasDeletesInsertsMoves || hasUpdates)
                }
            }

            deleteInsertMoveCellItems(for: diffResult) { changed in
                hasDeletesInsertsMoves = changed
                complete()
            }

            updateCellItems(for: diffResult) { changed in
                hasUpdates = changed
                complete()
            }
        }
    }

    private func updateSectionItems(with updates: [CollectionViewUpdate<CollectionViewDiffableSectionItem>]) {
        if updates.isEmpty {
            return
        }
        var indexes: [Int] = []
        var items: [CollectionViewDiffableSectionItem] = []
        for update in updates {
            indexes.append(update.index)
            items.append(update.newItem)
        }
        replace(sectionItemsAt: indexes, with: items, performUpdates: false)
    }

    private func deleteSectionItems(with deletes: [CollectionViewDeleteInsert<CollectionViewDiffableSectionItem>]) {
        if deletes.isEmpty {
            return
        }
        let indexes: [Int] = deletes.map { $0.index }
        remove(sectionItemsAt: indexes)
    }

    private func insertSectionItems(with inserts: [CollectionViewDeleteInsert<CollectionViewDiffableSectionItem>]) {
        if inserts.isEmpty {
            return
        }
        var indexes: [Int] = []
        var items: [CollectionViewDiffableSectionItem] = []
        for insert in inserts {
            indexes.append(insert.index)
            items.append(insert.item)
        }
        insert(items, at: indexes, performUpdates: false)
    }

    private func moveSectionItems(with moves: [CollectionViewMove<CollectionViewDiffableSectionItem>]) {
        if moves.isEmpty {
            return
        }
        sectionItems = updatedItems(sectionItems, with: moves)
        for move in moves {
            collectionView.moveSection(move.from, toSection: move.to)
        }
    }

    // MARK: - Cell Items

    private func deleteInsertMoveCellItems(for diffResult: CollectionViewDiffResult, completion: DiffCompletion?) {
        guard diffResult.hasCellDeletesInsertsMoves else {
            completion?(false)
            return
        }
        collectionView.performBatchUpdates({
            diffResult.cellDeletesInsertsMovesMap.forEach { (update, cellChanges) in
                deleteCellItems(with: cellChanges.deletes, in: update.oldItem)
                insertCellItems(with: cellChanges.inserts, in: update.oldItem)
                moveCellItems(with: cellChanges.moves, in: update.oldItem)
            }
            recalculateIndexes()
        }, completion: { _ in
            completion?(true)
        })
    }

    private func updateCellItems(for diffResult: CollectionViewDiffResult, completion: DiffCompletion?) {
        guard diffResult.hasSectionUpdates ||
            diffResult.hasCellUpdates else {
                completion?(false)
                return
        }
        collectionView.performBatchUpdates({
            diffResult.cellUpdatesMap.forEach { (update, cellChanges) in
                updateCellItems(with: cellChanges.updates, in: update.oldItem)
            }
            updateSectionItems(with: diffResult.sectionUpdates)
        }, completion: { _ in
            completion?(true)
        })
    }

    private func updateCellItems(with updates: [CollectionViewUpdate<CollectionViewDiffableCellItem>],
                                 in sectionItem: CollectionViewSectionItem) {
        if updates.isEmpty {
            return
        }
        var indexes: [Int] = []
        var items: [CollectionViewDiffableCellItem] = []
        for update in updates {
            indexes.append(update.index)
            items.append(update.newItem)
        }
        replace(cellItemsAt: indexes, with: items, in: sectionItem, performUpdates: false)
    }

    private func deleteCellItems(with deletes: [CollectionViewDeleteInsert<CollectionViewDiffableCellItem>],
                                 in sectionItem: CollectionViewSectionItem) {
        if deletes.isEmpty {
            return
        }
        let indexes: [Int] = deletes.map { $0.index }
        removeCellItems(at: indexes, from: sectionItem)
    }

    private func insertCellItems(with inserts: [CollectionViewDeleteInsert<CollectionViewDiffableCellItem>],
                                 in sectionItem: CollectionViewSectionItem) {
        if inserts.isEmpty {
            return
        }
        var indexes: [Int] = []
        var items: [CollectionViewDiffableCellItem] = []
        for insert in inserts {
            indexes.append(insert.index)
            items.append(insert.item)
        }
        insert(items, to: sectionItem, at: indexes, performUpdates: false)
    }

    private func moveCellItems(with moves: [CollectionViewMove<CollectionViewDiffableCellItem>],
                               in sectionItem: CollectionViewSectionItem) {
        if moves.isEmpty {
            return
        }
        sectionItem.cellItems = updatedItems(sectionItem.cellItems, with: moves)
        for move in moves {
            guard let section = sectionItem.index else {
                return
            }
            collectionView.moveItem(at: IndexPath(item: move.from, section: section),
                                    to: IndexPath(item: move.to, section: section))
        }
    }

    // MARK: - Diff Result

    private enum AssociatedKeys {
        static var diffResultQueue = "rsb_diffResultQueue"
    }
    
    private var diffResultQueue: DispatchQueue {
        get {
            if let diffResultQueue = objc_getAssociatedObject(self, &AssociatedKeys.diffResultQueue) as? DispatchQueue {
                return diffResultQueue
            }
            self.diffResultQueue = DispatchQueue.global()
            return self.diffResultQueue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.diffResultQueue, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private func calculateDiffResult(for sectionItems: [CollectionViewDiffableSectionItem],
                                     diff: CollectionViewDiff,
                                     completion: @escaping (CollectionViewDiffResult?) -> Void) {
        diffResultQueue.async {
            let oldSectionItems = self.diffableSectionItems
            let sectionDiffs = diff.changes(old: self.diffableItemWrappers(for: oldSectionItems),
                                            new: self.diffableItemWrappers(for: sectionItems))
            if sectionDiffs.isEmpty {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            let sectionChanges = CollectionViewChanges<CollectionViewDiffableSectionItem>(changes: sectionDiffs)
            var cellChangesMap: CollectionViewDiffResult.CellChangesMap = [:]
            for update in sectionChanges.updates {
                let cellDiffs = diff.changes(old: self.diffableItemWrappers(for: update.oldItem.diffableCellItems),
                                             new: self.diffableItemWrappers(for: update.newItem.diffableCellItems))
                if cellDiffs.isEmpty {
                    continue
                }
                let cellChanges = CollectionViewChanges<CollectionViewDiffableCellItem>(changes: cellDiffs)
                cellChangesMap[update] = cellChanges
            }
            let result = CollectionViewDiffResult(sectionChanges: sectionChanges, cellChangesMap: cellChangesMap)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Helpers

    private func updatedItems<T, U>(_ items: [T], with moves: [CollectionViewMove<U>]) -> [T] {
        var items = items
        var fromIndexes: [Int] = []
        for move in moves {
            guard let moveItem = move.item as? CollectionViewDiffableItem else {
                continue
            }
            let fromIndex = items.firstIndex { item -> Bool in
                guard let item = item as? CollectionViewDiffableItem else {
                    return false
                }
                return item.diffIdentifier == moveItem.diffIdentifier
            }
            fromIndexes.append(fromIndex ?? move.from)
        }
        let orderedByFromMoveTuples = zip(fromIndexes, moves).sorted { (lhs, rhs) -> Bool in
            lhs.0 > rhs.0
        }
        for tuple in orderedByFromMoveTuples {
            let (index, move) = tuple
            if let item = items[index] as? U {
                move.item = item
            }
            items.remove(at: index)
        }
        let orderedByToMoves = moves.sorted { (lhs, rhs) -> Bool in
            lhs.to < rhs.to
        }
        for move in orderedByToMoves {
            if let item = move.item as? T {
                items.insert(item, at: move.to)
            }
        }
        return items
    }

    private func diffableItemWrappers(for items: [CollectionViewDiffableItem]) -> [CollectionViewDiffableItemWrapper] {
        return items.map { CollectionViewDiffableItemWrapper(item: $0) }
    }
}
