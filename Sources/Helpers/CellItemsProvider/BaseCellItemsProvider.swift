//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class BaseSectionItemsProvider: SectionItemsProvider {

    public var sectionItems: [CollectionViewSectionItem] = []

    public var numberOfSections: Int {
        sectionItems.count
    }

    public var reuseTypes: [ReuseType]

    public subscript(index: Int) -> CollectionViewSectionItem {
        get {
            sectionItems[index]
        }
        set {
            sectionItems[index] = newValue
        }
    }

    public subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            guard indexPath.row < sectionItems[indexPath.section].cellItems.count else {
                return nil
            }
            return sectionItems[indexPath.section].cellItems[indexPath.row]
        }
        set {
            if let cellItem = newValue {
                sectionItems[indexPath.section].cellItems[indexPath.row] = cellItem
            }
            else {
                sectionItems[indexPath.section].cellItems.remove(at: indexPath.row)
            }
        }
    }

    init() {
        reuseTypes = sectionItems.flatMap { sectionItem in
            sectionItem.cellItems.map { cellItem in
                cellItem.reuseType
            }
        }
    }

    public func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
        guard let cellItem = self[indexPath],
            let sectionItem = cellItem.sectionItem else {
            return .zero
        }
        let size = cellItem.size(in: collectionView, sectionItem: sectionItem)
        if cellItem.cachedSize == nil {
            cellItem.cachedSize = size
        }
        return size
    }

    public func insert(_ sectionItem: CollectionViewSectionItem, at index: Int) {
        sectionItems.insert(sectionItem, at: index)
    }

    public func insert(contentsOf collection: [CollectionViewSectionItem], at index: Int) {
        sectionItems.insert(contentsOf: collection, at: index)
    }

    public func remove(at index: Int) {
        sectionItems.remove(at: index)
    }

    public func remove(at indexPath: IndexPath) {
        sectionItems[indexPath.section].cellItems.remove(at: indexPath.row)
    }

    public func forEachCellItem(actionHandler: (Int, CollectionViewCellItem) -> Void) {
        sectionItems.forEach { sectionItem in
            sectionItem.cellItems.enumerated().forEach(actionHandler)
        }
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return sectionItems[section].cellItems.count
    }

    public func sectionItem(at index: Int) -> CollectionViewSectionItem {
        sectionItems[index]
    }

    public func firstIndex(of sectionItem: CollectionViewSectionItem) -> Int? {
        sectionItems.firstIndex { element in
            element === sectionItem
        }
    }

    public func move(cellItemAt indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionItem = sectionItems[indexPath.section]
        let destinationIndexPathSectionItem = sectionItems[destinationIndexPath.section]
        let cellItem = sourceSectionItem.cellItems.remove(at: indexPath.row)
        destinationIndexPathSectionItem.cellItems.insert(cellItem, at: destinationIndexPath.row)
    }
}
