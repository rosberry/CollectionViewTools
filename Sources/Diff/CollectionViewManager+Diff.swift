//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

/// Extension that allows you to use CollectionViewManager with diff algorithms.
extension CollectionViewManager {

    public typealias DiffCompletion = (Bool) -> Void

    /// Array of `CollectionViewDiffSectionItem` objects mapped from `sectionItems` array
    var diffSectionItems: [CollectionViewDiffSectionItem] {
        return sectionItemsProvider.sectionItems.compactMap { sectionItem in
            sectionItem as? CollectionViewDiffSectionItem
        }
    }

    /// Use this function if you need to set new diff section items.
    /// This function uses DeepDiff dependency to perform diff logic.
    /// - Parameters:
    ///   - sectionItems: Array of `CollectionViewDiffSectionItem` objects.
    ///   - ignoreCellItemsChanges: If this value is `true` animation of cell insertions/deletions/updates is replaced by section update animation.
    ///   - animated: Animates all sections and cells insertions/deletions/updates. If this value is `false` diff algorithm is disabled and section items just replace old section items.
    ///   - completion: Will be called when all updates finish.
    open func update(with sectionItems: [CollectionViewDiffSectionItem],
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: DiffCompletion? = nil) {
        update(with: sectionItems,
               diffAdaptor: CollectionViewDeepDiffAdaptor(),
               ignoreCellItemsChanges: ignoreCellItemsChanges,
               animated: animated,
               completion: completion)
    }

    /// Use this function if you need to set new diff section items.
    /// - Parameters:
    ///   - sectionItems: Array of `CollectionViewDiffSectionItem` objects.
    ///   - diffAdaptor: Use `diffAdaptor` to implement your own diff algorithm
    ///   - ignoreCellItemsChanges: If this value is `true` animation of cell insertions/deletions/updates is replaced by section update animation.
    ///   - animated: Animates all sections and cells insertions/deletions/updates. If this value is `false` diff algorithm is disabled and section items just replace old section items.
    ///   - completion: Will be called when all updates finish.
    open func update(with sectionItems: [CollectionViewDiffSectionItem],
                     diffAdaptor: CollectionViewDiffAdaptor,
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: DiffCompletion? = nil) {
        if animated {
            if self.sectionItemsProvider.sectionItems.isEmpty {
                updateEmptyCollectionView(with: sectionItems, completion: completion)
                return
            }
            updateCollectionView(with: sectionItems,
                                 diffResult: .diffResult(for: sectionItems, in: self, diff: diffAdaptor),
                                 ignoreCellItemsChanges: ignoreCellItemsChanges,
                                 animated: animated,
                                 completion: completion)
        }
        else {
            updateWithoutAnimation(sectionItems: sectionItems, shouldReload: true)
            completion?(true)
        }
    }

    // MARK: - Private

    private func logBadItems(for sectionItems: [CollectionViewDiffSectionItem]) {
        guard isLoggingEnabled else {
            return
        }

        var badSectionItems: [CollectionViewSectionItem] = []
        var badCellItems: [CollectionViewCellItem] = []
        var badReusableViewItems: [CollectionViewReusableViewItem] = []

        for sectionItem in sectionItems {
            if sectionItem.diffIdentifier.isEmpty {
                badSectionItems.append(sectionItem)
            }
            for cellItem in sectionItem.cellItems {
                guard let diffCellItem = cellItem as? CollectionViewDiffCellItem else {
                    badCellItems.append(cellItem)
                    continue
                }
                if diffCellItem.diffIdentifier.isEmpty {
                    badCellItems.append(diffCellItem)
                }
            }
            for viewItem in sectionItem.reusableViewItems {
                guard let diffViewItem = viewItem as? CollectionViewDiffReusableViewItem else {
                    badReusableViewItems.append(viewItem)
                    continue
                }
                if diffViewItem.diffIdentifier.isEmpty {
                    badReusableViewItems.append(diffViewItem)
                }
            }
        }
        if badSectionItems.isEmpty,
           badCellItems.isEmpty,
           badReusableViewItems.isEmpty {
            return
        }

        print("⚠️ CollectionViewTools Warning!!! Following items have empty diffIdentifier:")
        for sectionItem in badSectionItems {
            if let index = sectionItem.index {
                print("\(type(of: sectionItem)) at index \(index)")
            }
        }
        for viewItem in badReusableViewItems {
            if let index = viewItem.sectionItem?.index {
                print("\(type(of: viewItem)) in section at index \(index)")
            }
        }
        for cellItem in badCellItems {
            if let indexPath = cellItem.indexPath {
                print("\(type(of: cellItem)) at indexpath (\(indexPath.section), \(indexPath.item))")
            }
        }
    }

    private func updateWithoutAnimation(sectionItems: [CollectionViewDiffSectionItem], shouldReload: Bool) {
        sectionItemsProvider.sectionItems = sectionItems
        registerSectionItems()
        recalculateIndexes()

        logBadItems(for: sectionItems)

        if shouldReload {
            collectionView.reloadData()
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

        registerSectionItems()
        recalculateIndexes()

        logBadItems(for: sectionItems)

        itemsWereUpdated = true
        complete()
    }

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
                switch cellUpdateMode {
                case .soft:
                    softUpdate(cellItemsAt: cellChanges.updatedIndexes,
                               with: cellChanges.updatedItems,
                               in: update.oldItem,
                               performUpdates: false,
                               configureAnimated: animated)
                case .hard:
                    replace(cellItemsAt: cellChanges.updatedIndexes,
                            with: cellChanges.updatedItems,
                            in: update.oldItem,
                            performUpdates: false,
                            configureAnimated: animated)
                }
            }
            if diffResult.hasSectionUpdates {
                var sectionUpdatedIndexes: [Int] = []
                var sectionUpdatedItems: [CollectionViewDiffSectionItem] = []
                for update in diffResult.sectionUpdates {
                    let areInsetsAndSpacingsEqual = update.newItem.areInsetsAndSpacingsEqual(to: update.oldItem)
                    let areReusableViewsEqual = update.newItem.areReusableViewsEqual(to: update.oldItem)
                    guard !areInsetsAndSpacingsEqual || !areReusableViewsEqual else {
                        continue
                    }
                    sectionUpdatedIndexes.append(update.index)
                    sectionUpdatedItems.append(update.newItem)
                }
                replace(sectionItemsAt: sectionUpdatedIndexes, with: sectionUpdatedItems, performUpdates: false)
            }
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
            guard let moveItem = move.item as? DiffItem else {
                continue
            }
            let fromIndex = items.firstIndex { item -> Bool in
                guard let item = item as? DiffItem else {
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
}
