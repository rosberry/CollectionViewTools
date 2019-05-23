//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

private enum AssociatedKeys {
    static var diffQueue = "rsb_diffQueue"
}

extension CollectionViewManager {

    var diffableSectionItems: [CollectionViewDiffableSectionItem] {
        return sectionItems.compactMap { $0 as? CollectionViewDiffableSectionItem }
    }

    var diffQueue: DispatchQueue {
        get {
            if let diffQueue = objc_getAssociatedObject(self, &AssociatedKeys.diffQueue) as? DispatchQueue {
                return diffQueue
            }
            self.diffQueue = DispatchQueue.global()
            return self.diffQueue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.diffQueue, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    @discardableResult
    open func update(with sectionItems: [CollectionViewDiffableSectionItem],
                     diff: CollectionViewDiff,
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: ((Bool) -> Void)? = nil) -> Bool {
        if animated {
            if self.sectionItems.isEmpty {
                if sectionItems.isEmpty {
                    return false
                }
                insert(sectionItems, at: Array(0..<sectionItems.count), performUpdates: true, completion: completion)
                recalculateIndexes()
                return true
            }
            calculateDiffResult(for: sectionItems, diff: diff) { result in
                guard let result = result else {
                    return
                }
                let dispatchGroup = DispatchGroup()

                dispatchGroup.enter()
                self.deleteInsertMoveSectionItems(for: result) { _ in
                    dispatchGroup.leave()
                }

                dispatchGroup.enter()
                self.updateSectionItems(for: result, ignoreCellItemsChanges: ignoreCellItemsChanges) { _ in
                    dispatchGroup.leave()
                }

                if !ignoreCellItemsChanges {
                    for update in result.sectionChanges.updates {
                        if let cellChanges = result.cellChangesMap[update.index] {
                            self.updateCellItems(with: cellChanges.updates, in: update.oldItem)
                        }
                    }
                }

                dispatchGroup.notify(queue: .main, execute: {
                    completion?(true)
                })
            }
            return true
        }
        else {
            self.update(sectionItems, shouldReloadData: true)
            return true
        }
    }

    private func calculateDiffResult(for sectionItems: [CollectionViewDiffableSectionItem],
                                     diff: CollectionViewDiff,
                                     completion: @escaping (CollectionViewDiffResult?) -> Void) {
        diffQueue.async {
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
                cellChangesMap[update.index] = cellChanges
            }
            let result = CollectionViewDiffResult(sectionChanges: sectionChanges, cellChangesMap: cellChangesMap)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Section Items

    private func deleteInsertMoveSectionItems(for result: CollectionViewDiffResult,
                                              completion: @escaping (Bool) -> Void) {
        collectionView.performBatchUpdates({
            deleteSectionItems(with: result.sectionChanges.deletes)
            insertSectionItems(with: result.sectionChanges.inserts)
            moveSectionItems(with: result.sectionChanges.moves)
            recalculateIndexes()
        }, completion: completion)
    }

    private func updateSectionItems(for result: CollectionViewDiffResult,
                                    ignoreCellItemsChanges: Bool,
                                    completion: @escaping (Bool) -> Void) {
        if result.sectionChanges.updates.count > 0 {
            collectionView.performBatchUpdates({
                if ignoreCellItemsChanges {
                    updateSectionItems(with: result.sectionChanges.updates)
                }
                else {
                    var sectionUpdates: [CollectionViewUpdate<CollectionViewDiffableSectionItem>] = []
                    for update in result.sectionChanges.updates {
                        if let cellChanges = result.cellChangesMap[update.index] {
                            deleteCellItems(with: cellChanges.deletes, in: update.oldItem)
                            insertCellItems(with: cellChanges.inserts, in: update.oldItem)
                            moveCellItems(with: cellChanges.moves, in: update.oldItem)
                        }
                        else {
                            sectionUpdates.append(update)
                        }
                    }
                    if sectionUpdates.count > 0 {
                        updateSectionItems(with: sectionUpdates)
                    }
                }
                update(sectionItems, shouldReloadData: false)
                recalculateIndexes()
            }, completion: completion)
        }
        else {
            update(sectionItems, shouldReloadData: false)
            recalculateIndexes()
            completion(true)
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
        sectionItems = updatedItems(for: sectionItems, with: moves)
        for move in moves {
            collectionView.moveSection(move.from, toSection: move.to)
        }
    }

    // MARK: - Cell Items

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
        sectionItem.cellItems = updatedItems(for: sectionItem.cellItems, with: moves)
        for move in moves {
            guard let section = sectionItem.index else {
                return
            }
            collectionView.moveItem(at: IndexPath(item: move.from, section: section),
                                    to: IndexPath(item: move.to, section: section))
        }
    }

    // MARK: - Helpers

    private func updatedItems<T, U>(for items: [T], with moves: [CollectionViewMove<U>]) -> [T] {
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
