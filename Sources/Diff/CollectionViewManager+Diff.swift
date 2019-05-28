//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

extension CollectionViewManager {

    public typealias DiffCompletion = (Bool) -> Void

    open func update(with sectionItems: [CollectionViewDiffSectionItem],
                     diff: CollectionViewDiff,
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: DiffCompletion? = nil) {
        if animated {
            if self.sectionItems.isEmpty {
                updateEmptyCollectionView(with: sectionItems, completion: completion)
                return
            }
            diffResultProvider.diffResult(for: sectionItems, in: self, diff: diff) { diffResult in
                self.updateCollectionView(with: sectionItems,
                                          diffResult: diffResult,
                                          ignoreCellItemsChanges: ignoreCellItemsChanges,
                                          animated: animated,
                                          completion: completion)
            }
        }
        else {
            update(sectionItems, shouldReloadData: true)
            completion?(true)
        }
    }

    private func updateEmptyCollectionView(with sectionItems: [CollectionViewDiffSectionItem], completion: DiffCompletion?) {
        if sectionItems.isEmpty {
            completion?(false)
            return
        }
        insert(sectionItems, at: Array(0..<sectionItems.count), performUpdates: true) { _ in
            completion?(true)
        }
        recalculateIndexes()
    }

    private func updateCollectionView(with sectionItems: [CollectionViewDiffSectionItem],
                                      diffResult: CollectionViewDiffResult?,
                                      ignoreCellItemsChanges: Bool,
                                      animated: Bool,
                                      completion: DiffCompletion?) {
        guard let diffResult = diffResult else {
            diffResultProvider.semaphore.signal()
            completion?(false)
            return
        }
        var hasDeletesInsertsMoves: Bool?
        var hasUpdates: Bool?
        var itemsWereUpdated: Bool?

        func complete() {
            if let hasDeletesInsertsMoves = hasDeletesInsertsMoves,
               let hasUpdates = hasUpdates,
               itemsWereUpdated != nil {
                configureCellItems()
                completion?(hasDeletesInsertsMoves || hasUpdates)
            }
        }

        deleteInsertMoveSectionItems(for: diffResult) { changed in
            hasDeletesInsertsMoves = changed
            complete()
        }
        updateSectionItems(for: diffResult, ignoreCellItemsChanges: ignoreCellItemsChanges, animated: animated) { changed in
            hasUpdates = changed
            complete()
        }

        update(sectionItems, shouldReloadData: false)
        recalculateIndexes()
        diffResultProvider.semaphore.signal()
        itemsWereUpdated = true
        complete()
    }

    // MARK: - Items

    private func deleteInsertMoveSectionItems(for diffResult: CollectionViewDiffResult, completion: DiffCompletion?) {
        guard diffResult.sectionChanges.hasDeletes ||
            diffResult.sectionChanges.hasInserts ||
            diffResult.sectionChanges.hasMoves else {
                completion?(false)
                return
        }
        collectionView.performBatchUpdates({
            remove(sectionItemsAt: diffResult.sectionChanges.deletedIndexes,
                   performUpdates: false)
            insert(diffResult.sectionChanges.insertedItems,
                   at: diffResult.sectionChanges.insertedIndexes,
                   performUpdates: false)
            moveSectionItems(with: diffResult.sectionChanges.moves)
            recalculateIndexes()
        }, completion: { _ in
            completion?(true)
        })
    }

    private func updateSectionItems(for diffResult: CollectionViewDiffResult,
                                    ignoreCellItemsChanges: Bool,
                                    animated: Bool,
                                    completion: DiffCompletion?) {
        guard diffResult.sectionChanges.hasUpdates else {
            completion?(false)
            return
        }
        if ignoreCellItemsChanges {
            replace(sectionItemsAt: diffResult.sectionChanges.updatedIndexes,
                    with: diffResult.sectionChanges.updatedItems,
                    performUpdates: false)
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
            updateCellItems(for: diffResult, animated: animated) { changed in
                hasUpdates = changed
                complete()
            }
        }
    }

    private func moveSectionItems(with moves: [CollectionViewMove<CollectionViewDiffSectionItem>]) {
        sectionItems = updatedItems(sectionItems, with: moves)
        for move in moves {
            collectionView.moveSection(move.from, toSection: move.to)
        }
    }

    private func deleteInsertMoveCellItems(for diffResult: CollectionViewDiffResult, completion: DiffCompletion?) {
        guard diffResult.hasCellDeletesInsertsMoves else {
            completion?(false)
            return
        }
        collectionView.performBatchUpdates({
            diffResult.cellDeletesInsertsMovesMap.forEach { (update, cellChanges) in
                removeCellItems(at: cellChanges.deletedIndexes,
                                from: update.oldItem,
                                performUpdates: false)
                insert(cellChanges.insertedItems,
                       to: update.oldItem,
                       at: cellChanges.insertedIndexes,
                       performUpdates: false)
                moveCellItems(with: cellChanges.moves, in: update.oldItem)
            }
            recalculateIndexes()
        }, completion: { _ in
            completion?(true)
        })
    }

    private func updateCellItems(for diffResult: CollectionViewDiffResult,
                                 animated: Bool,
                                 completion: @escaping DiffCompletion) {
        guard diffResult.hasSectionUpdates ||
            diffResult.hasCellUpdates else {
                completion(false)
                return
        }
        collectionView.performBatchUpdates({
            diffResult.cellUpdatesMap.forEach { (update, cellChanges) in
                replace(cellItemsAt: cellChanges.updatedIndexes,
                        with: cellChanges.updatedItems,
                        in: update.oldItem,
                        performUpdates: false,
                        configureAnimated: animated)
            }
            replace(sectionItemsAt: diffResult.sectionChanges.updatedIndexes,
                    with: diffResult.sectionChanges.updatedItems,
                    performUpdates: false)
        }, completion: { _ in
            completion(true)
        })
    }

    private func moveCellItems(with moves: [CollectionViewMove<CollectionViewDiffCellItem>],
                               in sectionItem: CollectionViewSectionItem) {
        sectionItem.cellItems = updatedItems(sectionItem.cellItems, with: moves)
        for move in moves {
            guard let section = sectionItem.index else {
                return
            }
            collectionView.moveItem(at: IndexPath(item: move.from, section: section),
                                    to: IndexPath(item: move.to, section: section))
        }
    }

    private func updatedItems<T, U>(_ items: [T], with moves: [CollectionViewMove<U>]) -> [T] {
        if moves.isEmpty {
            return items
        }
        var items = items
        var fromIndexes: [Int] = []
        for move in moves {
            guard let moveItem = move.item as? CollectionViewDiffItem else {
                continue
            }
            let fromIndex = items.firstIndex { item -> Bool in
                guard let item = item as? CollectionViewDiffItem else {
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

    // MARK: - Diff Result

    private enum AssociatedKeys {
        static var diffResultProvider = "rsb_diffResultProvider"
    }

    private var diffResultProvider: CollectionViewDiffResultProvider {
        get {
            if let provider = objc_getAssociatedObject(self, &AssociatedKeys.diffResultProvider) as? CollectionViewDiffResultProvider {
                return provider
            }
            self.diffResultProvider = .init()
            return self.diffResultProvider
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.diffResultProvider, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
