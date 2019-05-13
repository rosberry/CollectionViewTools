//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

extension CollectionViewManager {

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
            let sectionDiffs = diffs(old: oldSectionItems, new: sectionItems, diff: diff)
            if sectionDiffs.isEmpty {
                return false
            }
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.performBatchUpdates({
                let sectionChanges = CollectionViewChanges<CollectionViewDiffableSectionItem>(changes: sectionDiffs)
                if ignoreCellItemsChanges {
                    self.replace(sectionItemsAt: sectionChanges.replacedIndexes,
                                 with: sectionChanges.replacedItems,
                                 performUpdates: false)
                }
                else {
                    zip(sectionChanges.oldReplacedItems, sectionChanges.replacedItems).forEach { (oldSection, section) in
                        let cellDiffs = self.diffs(old: oldSection.diffableCellItems, new: section.diffableCellItems, diff: diff)
                        if cellDiffs.isEmpty {
                            self.replace(sectionItemsAt: sectionChanges.replacedIndexes,
                                         with: sectionChanges.replacedItems,
                                         performUpdates: false)
                        }
                        else {
                            let cellChanges = CollectionViewChanges<CollectionViewDiffableCellItem>(changes: cellDiffs)
                            self.replace(cellItemsAt: cellChanges.replacedIndexes,
                                         with: cellChanges.replacedItems,
                                         in: oldSection,
                                         performUpdates: false)
                            self.removeCellItems(at: cellChanges.deletedIndexes,
                                                 from: oldSection,
                                                 performUpdates: false)
                            self.insert(cellChanges.insertedItems,
                                        to: oldSection,
                                        at: cellChanges.insertedIndexes,
                                        performUpdates: false)
                        }
                    }
                }
                self.remove(sectionItemsAt: sectionChanges.deletedIndexes,
                            performUpdates: false)
                self.insert(sectionChanges.insertedItems,
                            at: sectionChanges.insertedIndexes,
                            performUpdates: false)
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

    // MARK: - Private

    var diffableSectionItems: [CollectionViewDiffableSectionItem] {
        return sectionItems.compactMap { $0 as? CollectionViewDiffableSectionItem }
    }

    func diffs(old: [CollectionViewDiffableSectionItem],
               new: [CollectionViewDiffableSectionItem],
               diff: CollectionViewDiff) -> [CollectionViewChange<CollectionViewDiffableItemWrapper>] {
        func diffableItemWrappers(for sectionItems: [CollectionViewDiffableSectionItem])
            -> [CollectionViewDiffableItemWrapper] {
            return sectionItems.map { CollectionViewDiffableItemWrapper(item: $0) }
        }
        return diff.changes(old: diffableItemWrappers(for: old), new: diffableItemWrappers(for: new))
    }

    func diffs(old: [CollectionViewDiffableCellItem],
               new: [CollectionViewDiffableCellItem],
               diff: CollectionViewDiff) -> [CollectionViewChange<CollectionViewDiffableItemWrapper>] {
        func diffableItemWrappers(for sectionItems: [CollectionViewDiffableCellItem])
            -> [CollectionViewDiffableItemWrapper] {
            return sectionItems.map { CollectionViewDiffableItemWrapper(item: $0) }
        }
        return diff.changes(old: diffableItemWrappers(for: old), new: diffableItemWrappers(for: new))
    }
}
