//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class DefaultSectionItemsWrapper {
    public var sectionItems: [CollectionViewSectionItem] = []

    func registerKnownReuseTypes(in collectionView: UICollectionView) {
        sectionItems.forEach { sectionItem in
            sectionItem.cellItems.forEach { cellItem in
                collectionView.registerCell(with: cellItem.reuseType)
            }
        }
    }
}

// MARK: - IndustriousSectionItemsWrapper

extension DefaultSectionItemsWrapper: SectionItemsWrapper {

    var numberOfSections: Int {
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

    func insertSectionItem(_ sectionItem: CollectionViewSectionItem, at index: Int) {
        sectionItems.insert(sectionItem, at: index)
    }

    func insertSectionItems(_ sectionItems: [CollectionViewSectionItem], at index: Int) {
        self.sectionItems.insert(contentsOf: sectionItems, at: index)
    }

    func removeSectionItem(at index: Int) {
        sectionItems.remove(at: index)
    }

    func removeCellItem(at indexPath: IndexPath) {
        self[indexPath.section]?.cellItems.remove(at: indexPath.row)
    }

    func moveSectionItem(_ sectionItem: CollectionViewSectionItem?, at index: Int, to destinationIndex: Int) {
        guard let keySectionItem = sectionItem ?? self[index] else {
            return
        }
        sectionItems.remove(at: index)
        sectionItems.insert(keySectionItem, at: index)
    }

    func moveCellItem(at indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceSectionItem = self[indexPath.section],
              let destinationIndexPathSectionItem = self[destinationIndexPath.section] else {
            return
        }
        let cellItem = sourceSectionItem.cellItems.remove(at: indexPath.row)
        destinationIndexPathSectionItem.cellItems.insert(cellItem, at: destinationIndexPath.row)
    }

    func firstIndex(of keySectionItem: CollectionViewSectionItem) -> Int? {
        sectionItems.firstIndex { sectionItem in
            sectionItem === keySectionItem
        }
    }
}
