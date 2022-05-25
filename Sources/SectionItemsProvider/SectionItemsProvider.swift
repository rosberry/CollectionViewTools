//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Default implementation of `CollectionViewManager` implies that at any moment you have
/// actual `cellItem` for any cell that should be displayed. But when you works with large dataset
/// this way leads to performance decreasing. `SectionItemsProvider` simulates default workflow
/// to be able provide `cellItem` creation on demand. The obvious ways of implementation are
/// - Array based implementation that works in the default workflow
/// - Dictionary based implementation that provides access to `cellItem` and `sectionItem` on demand
 protocol SectionItemsProvider {
    /// Returns number of section that should be displayed
    var numberOfSectionItems: Int { get }

    /// Provides access to already initialized sectionItems or allows to write them
    var sectionItems: [CollectionViewSectionItem] { get set }

    /// Provides `sectionItem` by `index` if it is possible
    subscript(index: Int) -> CollectionViewSectionItem? { get set }

    /// Provides `cellItem` by `indexPath` if it is possible
    subscript(indexPath: IndexPath) -> CollectionViewCellItem? { get set }

    /// Returns number of cells in `section` that should be displayed
    func numberOfCellItems(inSection section: Int) -> Int

    /// Retuns size for cell item at `indexPath`.
    /// In the case of 'on demand' access it should not retrieve the object to calculate the size
    func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize

    /// Inserts `sectionItem` at `index` into according collection of created items
    func insert(_ sectionItem: CollectionViewSectionItem, at index: Int)

    /// Inserts `collection` of sectionItems  at `index` into according collection of created items
    func insert(_ sectionItems: [CollectionViewSectionItem], at index: Int)

    /// Removes `sectionItem` at `index` from according collection of created items
    func removeSectionItem(at index: Int)

    /// Removes cellItem at `indexPath` from according collection of created items
    func removeCellItem(at indexPath: IndexPath)

    /// Returns first index of `sectionItem` in according collection of created items
    func firstIndex(of sectionItem: CollectionViewSectionItem) -> Int?
}

extension SectionItemsProvider {
    func registerReuseTypes(in collectionView: UICollectionView) {
        sectionItems.forEach { sectionItem in
            sectionItem.cellItems.forEach { cellItem in
                collectionView.registerCell(with: cellItem.reuseType)
            }
        }
    }
}
