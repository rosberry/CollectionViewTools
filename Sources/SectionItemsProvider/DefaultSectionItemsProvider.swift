//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// It is an implementation of `SectionItemsProvider` that just wraps sectionItems array
/// and redirects to it all required methods
final class DefaultSectionItemsProvider {
    public var sectionItems: [CollectionViewSectionItem] = []
}

// MARK: - SectionItemsProvider

extension DefaultSectionItemsProvider: SectionItemsProvider {

    var numberOfSectionItems: Int {
        sectionItems.count
    }

    subscript(index: Int) -> CollectionViewSectionItem? {
        get {
            sectionItems[safe: index]
        }
        set {
            if let value = newValue {
                sectionItems[index] = value
            }
            else {
                sectionItems.remove(at: index)
            }
        }
    }

    subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            self[indexPath.section]?.cellItems[safe: indexPath.row]
        }
        set {
            if let value = newValue {
                self[indexPath.section]?.cellItems[indexPath.row] = value
            }
            else {
                self[indexPath.section]?.cellItems.remove(at: indexPath.row)
            }
        }
    }

    func numberOfCellItems(inSection section: Int) -> Int {
        self[section]?.cellItems.count ?? 0
    }

    func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
        guard let sectionItem = self[indexPath.section],
              let cellItem = sectionItem.cellItems[safe: indexPath.row] else {
                return .zero
        }
        let size = cellItem.size(in: collectionView, sectionItem: sectionItem)
        if cellItem.cachedSize == nil {
            cellItem.cachedSize = size
        }
        return size
    }

    func insert(_ sectionItem: CollectionViewSectionItem, at index: Int) {
        sectionItems.insert(sectionItem, at: index)
    }

    func insert(_ sectionItems: [CollectionViewSectionItem], at index: Int) {
        self.sectionItems.insert(contentsOf: sectionItems, at: index)
    }

    func removeSectionItem(at index: Int) {
        sectionItems.remove(at: index)
    }

    func removeCellItem(at indexPath: IndexPath) {
        self[indexPath.section]?.cellItems.remove(at: indexPath.row)
    }

    func firstIndex(of keySectionItem: CollectionViewSectionItem) -> Int? {
        sectionItems.firstIndex { sectionItem in
            sectionItem === keySectionItem
        }
    }
}
