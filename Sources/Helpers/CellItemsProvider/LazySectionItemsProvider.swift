//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class LazySectionItemsProvider: DictionarySectionItemsProvider {

    public var cellItemsNumberHandler: (Int) -> Int
    public var sectionItemsNumberHandler: () -> Int
    public var makeSectionItemHandler: (Int) -> CollectionViewSectionItem?
    public var makeCellItemHandler: (IndexPath) -> CollectionViewCellItem?
    public var sizeHandler: (IndexPath, UICollectionView) -> CGSize

    public override var isEmpty: Bool {
        sectionItemsNumberHandler() == 0
    }

    init(sectionItemsNumberHandler: @escaping () -> Int,
         cellItemsNumberHandler: @escaping (Int) -> Int,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
         makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem?,
         makeCellItemHandler: @escaping (IndexPath) -> CollectionViewCellItem?) {
        self.cellItemsNumberHandler = cellItemsNumberHandler
        self.makeCellItemHandler = makeCellItemHandler
        self.sizeHandler = sizeHandler
        self.sectionItemsNumberHandler = sectionItemsNumberHandler
        self.makeSectionItemHandler = makeSectionItemHandler
        super.init()
    }

    public override subscript(index: Int) -> CollectionViewSectionItem? {
        get {
            if let sectionItem = sectionItemsDictionary[index] {
                return sectionItem
            }
            let sectionItem = makeSectionItemHandler(index)
            sectionItemsDictionary[index] = sectionItem
            return sectionItem
        }
        set {
            sectionItemsDictionary[index] = newValue
        }
    }

    public override subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            guard let sectionItem = self[indexPath.section] else {
                return nil
            }
            if let cellItem = sectionItem.cellItems[safe: indexPath.row] {
                return cellItem
            }
            guard let cellItem = makeCellItemHandler(indexPath) else {
                if indexPath.row < sectionItem.cellItems.count {
                    sectionItem.cellItems.remove(at: indexPath.row)
                }
                else {
                    fatalError("❌ CollectionViewTools Error!!! Could not retrieve a cell item for indexPath: \(indexPath). If you use custom factory please check that it can handle provider `objectHandler` return type.")
                }
                return nil
            }
            if indexPath.row < sectionItem.cellItems.count {
                sectionItem.cellItems[indexPath.row] = cellItem
            }
            else if indexPath.row == sectionItem.cellItems.count {
                sectionItem.cellItems.append(cellItem)
            }
            else {
                fatalError("Invalid cell item insertion")
            }

            return cellItem
        }
        set {
            if let cellItem = newValue {
                self[indexPath.section]?.cellItems[indexPath.row] = cellItem
            }
            else {
                self[indexPath.section]?.cellItems.remove(at: indexPath.row)
            }
        }
    }

    public override func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
        sizeHandler(indexPath, collectionView)
    }

    public override var numberOfSections: Int {
        sectionItemsNumberHandler()
    }

    public override func numberOfItems(inSection section: Int) -> Int {
        cellItemsNumberHandler(section)
    }
}
