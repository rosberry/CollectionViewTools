//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class DictionarySectionItemsProvider: SectionItemsProvider {
    
    var sectionItemsDictionary: [Int: CollectionViewSectionItem] = [:]
    var removedCellItems: [IndexPath: CollectionViewCellItem] = [:]

    public var numberOfSections: Int {
        sectionItemsDictionary.count
    }

    public var sectionItems: [CollectionViewSectionItem] {
        get {
            Array(sectionItemsDictionary.values)
        }
        set {
            sectionItemsDictionary = [:]
            newValue.enumerated().forEach { key, value in
                sectionItemsDictionary[key] = value
            }
        }
    }

    public var isEmpty: Bool {
        sectionItems.isEmpty
    }

    public subscript(index: Int) -> CollectionViewSectionItem? {
        get {
            sectionItems[index]
        }
        set {
            sectionItemsDictionary[index] = newValue
        }
    }

    public subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            guard let sectionItem = self[indexPath.section],
                indexPath.row < sectionItem.cellItems.count else {
                return nil
            }
            let cellItem = sectionItem.cellItems[indexPath.row]
            cellItem.sectionItem = sectionItem
            return cellItem
        }
        set {
            if let cellItem = newValue {
                guard let sectionItem = self[indexPath.section] else {
                    return
                }
                cellItem.sectionItem = sectionItem
                sectionItem.cellItems[indexPath.row] = cellItem
            }
            else {
                sectionItemsDictionary[indexPath.section]?.cellItems.remove(at: indexPath.row)
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
        for key in sectionItemsDictionary.keys.sorted(by: >) where key >= index {
            self[key + 1] = sectionItems[key]
        }
        self[index] = sectionItem
    }

    public func insert(contentsOf collection: [CollectionViewSectionItem], at index: Int) {
        for key in sectionItemsDictionary.keys.sorted(by: >) where key >= index + collection.count {
            self[key + collection.count] = self[key]
        }
        collection.enumerated().forEach { offset, sectionItem in
            self[offset + index] = sectionItem
        }
    }

    public func remove(at index: Int) {
        for key in sectionItemsDictionary.keys.sorted() where key >= index {
            self[key] = self[key + 1]
        }
    }

    public func remove(at indexPath: IndexPath) {
        let cellItem = self[indexPath.section]?.cellItems.remove(at: indexPath.row)
        removedCellItems[indexPath] = cellItem
    }

    public func forEachCellItem(actionHandler: (Int, CollectionViewCellItem) -> Void) {
        sectionItemsDictionary.values.forEach { sectionItem in
            for i in 0..<sectionItem.cellItems.count {
                actionHandler(i, sectionItem.cellItems[i])
            }
        }
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return self[section]?.cellItems.count ?? 0
    }

    public func firstIndex(of sectionItem: CollectionViewSectionItem) -> Int? {
        sectionItemsDictionary.first { _, element in
            element === sectionItem
        }?.key
    }

    public func move(sectionItem: CollectionViewSectionItem?, at index: Int, to destinationIndex: Int) {
        let keySectionItem = sectionItem ?? sectionItems[index]
        sectionItemsDictionary.removeValue(forKey: index)
        self[destinationIndex] = keySectionItem
    }

    public func move(cellItemAt indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionItem = self[indexPath.section]
        let destinationIndexPathSectionItem = self[destinationIndexPath.section]
        if let cellItem = sourceSectionItem?.cellItems.remove(at: indexPath.row) {
            destinationIndexPathSectionItem?.cellItems.insert(cellItem, at: destinationIndexPath.row)
        }
    }

    public func registerKnownReuseTypes(in collectionView: UICollectionView) {
        // For lazy access we could not register some reuse types before
        // cellItem will be instantiated
    }

    public func registerIfNeeded(cellItem: CollectionViewCellItem) {
        // TODO: If it will lead to performance decreasing then use dictionary to check
        // registered identifiers and just remove this comment in other case
        cellItem.collectionView?.registerCell(with: cellItem.reuseType)
    }

    public func removedCellItem(at indexPath: IndexPath) -> CollectionViewCellItem? {
        removedCellItems[indexPath] ?? self[indexPath]
    }
}
