//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class DictionarySectionItemsProvider: SectionItemsProvider {
    
    var sectionItemsDictionary: [Int: CollectionViewSectionItem] = [:]

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

    private var cachedReuseTypes: [ReuseType]?

    public var reuseTypes: [ReuseType] {
        get {
            if let reuseTypes = cachedReuseTypes {
                return reuseTypes
            }
            cachedReuseTypes = sectionItemsDictionary.values.flatMap { sectionItem in
                sectionItem.cellItems.map { cellItem in
                    cellItem.reuseType
                }
            }
            return cachedReuseTypes ?? []
        }
        set {
            cachedReuseTypes = newValue
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
            guard let sectionItem = sectionItemsDictionary[indexPath.section],
                indexPath.row < sectionItem.cellItems.count else {
                return nil
            }
            let cellItem = sectionItem.cellItems[indexPath.row]
            cellItem.sectionItem = sectionItem
            return cellItem
        }
        set {
            if let cellItem = newValue {
                guard let sectionItem = sectionItemsDictionary[indexPath.section] else {
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
        for key in sectionItemsDictionary.keys.sorted().reversed() where key >= index {
            sectionItems[key + 1] = sectionItems[key]
        }
        sectionItems[index] = sectionItem
    }

    public func insert(contentsOf collection: [CollectionViewSectionItem], at index: Int) {
        for key in sectionItemsDictionary.keys.sorted().reversed() where key >= index + collection.count {
            sectionItems[key + collection.count] = sectionItems[key]
        }
        collection.enumerated().forEach { offset, sectionItem in
            sectionItems[offset + index] = sectionItem
        }
    }

    public func remove(at index: Int) {
        for key in sectionItemsDictionary.keys.sorted() where key >= index {
            sectionItems[key] = sectionItems[key + 1]
        }
    }

    public func remove(at indexPath: IndexPath) {
        sectionItemsDictionary[indexPath.section]?.cellItems.remove(at: indexPath.row)
    }

    public func forEachCellItem(actionHandler: (Int, CollectionViewCellItem) -> Void) {
        sectionItemsDictionary.values.forEach { sectionItem in
            sectionItem.cellItems.enumerated().forEach(actionHandler)
        }
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return sectionItemsDictionary[section]?.cellItems.count ?? 0
    }

    public func firstIndex(of sectionItem: CollectionViewSectionItem) -> Int? {
        sectionItemsDictionary.first { _, element in
            element === sectionItem
        }?.key
    }

    public func move(sectionItem: CollectionViewSectionItem?, at index: Int, to destinationIndex: Int) {
        let keySectionItem = sectionItem ?? sectionItems[index]
        sectionItemsDictionary.removeValue(forKey: index)
        sectionItems[destinationIndex] = keySectionItem
    }

    public func move(cellItemAt indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionItem = sectionItemsDictionary[indexPath.section]
        let destinationIndexPathSectionItem = sectionItemsDictionary[destinationIndexPath.section]
        if let cellItem = sourceSectionItem?.cellItems.remove(at: indexPath.row) {
            destinationIndexPathSectionItem?.cellItems.insert(cellItem, at: destinationIndexPath.row)
        }
    }
}
