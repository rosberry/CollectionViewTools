//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class LazySectionItemsWrapper {

    var sectionItemsDictionary: [Int: CollectionViewSectionItem] = [:]

    // MARK: - Handlers

    public var cellItemsNumberHandler: (Int) -> Int
    public var sectionItemsNumberHandler: () -> Int
    public var makeSectionItemHandler: (Int) -> CollectionViewSectionItem?
    public var makeCellItemHandler: (IndexPath) -> CollectionViewCellItem?
    public var sizeHandler: (IndexPath, UICollectionView) -> CGSize

    // MARK: - Initializer

    /// `LazySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - sizeHandler: block that returns size of cell at index path
    init(sectionItemsNumberHandler: @escaping () -> Int,
         cellItemsNumberHandler: @escaping (Int) -> Int,
         makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem?,
         makeCellItemHandler: @escaping (IndexPath) -> CollectionViewCellItem?,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize) {
        self.cellItemsNumberHandler = cellItemsNumberHandler
        self.makeCellItemHandler = makeCellItemHandler
        self.sizeHandler = sizeHandler
        self.sectionItemsNumberHandler = sectionItemsNumberHandler
        self.makeSectionItemHandler = makeSectionItemHandler
    }

    /// `LazySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - factory: CellItemFactory to create and configure cellItems
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(factory: CellItemFactory,
                sectionItemsNumberHandler: @autoclosure @escaping () -> Int = 1,
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                objectHandler: @escaping (IndexPath) -> Any?) {

        self.cellItemsNumberHandler = cellItemsNumberHandler
        self.makeCellItemHandler = { indexPath in
            guard let object = objectHandler(indexPath) else {
                return nil
            }
            let cellItem = factory.makeCellItem(object: object, index: indexPath.row)
            return cellItem
        }
        self.sizeHandler = sizeHandler
        self.sectionItemsNumberHandler = sectionItemsNumberHandler
        self.makeSectionItemHandler = makeSectionItemHandler
    }

    /// `LazySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - cellConfigurationHandler: block to configure cell according it cell item
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init<U: GenericDiffItem, T: UICollectionViewCell>(
        sectionItemsNumberHandler: @autoclosure @escaping () -> Int = 1,
        cellItemsNumberHandler: @escaping (Int) -> Int,
        makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
            GeneralCollectionViewDiffSectionItem()
        },
        cellConfigurationHandler: ((T, UniversalCollectionViewCellItem<U, T>) -> Void)?,
        sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
        objectHandler: @escaping (IndexPath) -> Any?) {

        let factory = AssociatedCellItemFactory<U, T>()
        factory.cellConfigurationHandler = cellConfigurationHandler
        self.cellItemsNumberHandler = cellItemsNumberHandler

        self.makeCellItemHandler = { indexPath in
           guard let object = objectHandler(indexPath) else {
               return nil
           }
           return factory.makeCellItem(object: object, index: indexPath.row)
        }
        self.sizeHandler = sizeHandler
        self.sectionItemsNumberHandler = sectionItemsNumberHandler
        self.makeSectionItemHandler = makeSectionItemHandler
    }
}

// MARK: - SectionItemsWrapper

extension LazySectionItemsWrapper: SectionItemsWrapper {

    public subscript(index: Int) -> CollectionViewSectionItem? {
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

    public subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            guard let sectionItem = self[indexPath.section] else {
                return nil
            }
            if let cellItem = sectionItem.cellItems[safe: indexPath.row] {
                return cellItem
            }
            guard let cellItem = makeCellItemHandler(indexPath) else {
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

    func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize {
        sizeHandler(indexPath, collectionView)
    }

    var numberOfSections: Int {
        sectionItemsNumberHandler()
    }

    func numberOfCellItems(inSection section: Int) -> Int {
        cellItemsNumberHandler(section)
    }

    var sectionItems: [CollectionViewSectionItem] {
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

    func insertSectionItem(_ sectionItem: CollectionViewSectionItem, at index: Int) {
        for key in sectionItemsDictionary.keys.sorted(by: >) where key >= index {
            self[key + 1] = sectionItems[key]
        }
        self[index] = sectionItem
    }

    func insertSectionItems(_ sectionItems: [CollectionViewSectionItem], at index: Int) {
        for key in sectionItemsDictionary.keys.sorted(by: >) where key >= index + sectionItems.count {
            self[key + sectionItems.count] = self[key]
        }
        sectionItems.enumerated().forEach { offset, sectionItem in
            self[offset + index] = sectionItem
        }
    }

    func removeSectionItem(at index: Int) {
        for key in sectionItemsDictionary.keys.sorted() where key >= index {
            self[key] = self[key + 1]
        }
    }

    func removeCellItem(at indexPath: IndexPath) {
        self[indexPath.section]?.cellItems.remove(at: indexPath.row)
    }

    func firstIndex(of sectionItem: CollectionViewSectionItem) -> Int? {
        sectionItemsDictionary.first { _, element in
            element === sectionItem
        }?.key
    }

    func moveSectionItem(_ sectionItem: CollectionViewSectionItem?, at index: Int, to destinationIndex: Int) {
        let keySectionItem = sectionItem ?? sectionItems[index]
        sectionItemsDictionary.removeValue(forKey: index)
        self[destinationIndex] = keySectionItem
    }

    func moveCellItem(at indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionItem = self[indexPath.section]
        let destinationIndexPathSectionItem = self[destinationIndexPath.section]
        if let cellItem = sourceSectionItem?.cellItems.remove(at: indexPath.row) {
            destinationIndexPathSectionItem?.cellItems.insert(cellItem, at: destinationIndexPath.row)
        }
    }
}
