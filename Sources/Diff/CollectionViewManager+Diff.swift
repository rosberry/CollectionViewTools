//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

extension CollectionViewManager {

    var diffableSectionItems: [CollectionViewDiffableSectionItem] {
        return sectionItems.compactMap { $0 as? CollectionViewDiffableSectionItem }
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
            
            let oldSectionItems = diffableSectionItems
            let sectionDiffs = diff.changes(old: diffableItemWrappers(for: oldSectionItems),
                                            new: diffableItemWrappers(for: sectionItems))
            if sectionDiffs.isEmpty {
                return false
            }
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.performBatchUpdates({
                let sectionChanges = CollectionViewChanges<CollectionViewDiffableSectionItem>(changes: sectionDiffs)
                if ignoreCellItemsChanges {
                    self.updateSectionItems(with: sectionChanges.updates)
                }
                else {
                    for update in sectionChanges.updates {
                        let cellDiffs = diff.changes(old: diffableItemWrappers(for: update.oldItem.diffableCellItems),
                                                     new: diffableItemWrappers(for: update.newItem.diffableCellItems))
                        if cellDiffs.isEmpty {
                            self.updateSectionItems(with: sectionChanges.updates)
                        }
                        else {
                            let cellChanges = CollectionViewChanges<CollectionViewDiffableCellItem>(changes: cellDiffs)
                            let sectionItem = update.oldItem
                            self.updateCellItems(with: cellChanges.updates, in: sectionItem)
                            self.deleteCellItems(with: cellChanges.deletes, in: sectionItem)
                            self.insertCellItems(with: cellChanges.inserts, in: sectionItem)
                            self.moveCellItems(with: cellChanges.moves, in: sectionItem)
                        }
                    }
                }
                self.deleteSectionItems(with: sectionChanges.deletes)
                self.insertSectionItems(with: sectionChanges.inserts)
                self.moveSectionItems(with: sectionChanges.moves)

                self.update(sectionItems, shouldReloadData: false)
                self.recalculateIndexes()
            }, completion: completion)
            return true
        }
        else {
            self.update(sectionItems, shouldReloadData: true)
            return true
        }
    }

    // MARK: - Section Items

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
        for move in moves {
            self.move(sectionItemAt: move.from, to: move.to, sectionItem: move.item, performUpdates: false)
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
        for move in moves {
            self.move(cellItemAt: move.from, to: move.to, cellItem: move.item, in: sectionItem, performUpdates: false)
        }
    }

    // MARK: - Diffs

    private func diffableItemWrappers(for items: [CollectionViewDiffableItem]) -> [CollectionViewDiffableItemWrapper] {
        return items.map { CollectionViewDiffableItemWrapper(item: $0) }
    }
}
