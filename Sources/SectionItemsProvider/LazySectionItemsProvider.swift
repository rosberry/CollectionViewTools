//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// It is an implementation of `SectionItemsProvider` that organizes an access to required
/// cellItems and sectionItems on demand. It stores created section items in dictionary and calls
/// defined handlers to configure cell items if needed. There are 3 ways of usage:
/// - Describe all required handlers in initializer
/// - Provide a factory that will create cell items in initializer. Note that `sizeHandler` of factory will not working
///   because it needs an object as an argument, but it can't be retrieved yet.
///   `LazySectionItemsProvider` has own `sizeHandler` that should provide a size without
///   concrete object
/// - Use generic initializer that creates associated factory itself
public final class LazySectionItemsProvider {

    var sectionItemsDictionary: [Int: CollectionViewSectionItem] = [:]
    var collectionView: UICollectionView?

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
    ///    - factory: ComplexCellItemsFactory to create and configure cellItems
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(factory: ComplexCellItemsFactory,
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
            let cellItem = factory.makeCellItem(object: object)
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
    public init<U: DiffCompatible, T: UICollectionViewCell>(
        sectionItemsNumberHandler: @autoclosure @escaping () -> Int = 1,
        cellItemsNumberHandler: @escaping (Int) -> Int,
        makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
            GeneralCollectionViewDiffSectionItem()
        },
        cellConfigurationHandler: ((T, UniversalCollectionViewCellItem<U, T>) -> Void)?,
        sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
        objectHandler: @escaping (IndexPath) -> U?) {

        let factory = CellItemsFactory<U, T>()
        factory.cellConfigurationHandler = cellConfigurationHandler
        self.cellItemsNumberHandler = cellItemsNumberHandler

        self.makeCellItemHandler = { indexPath in
           guard let object = objectHandler(indexPath) else {
               return nil
           }
           return factory.makeCellItem(object: object)
        }
        self.sizeHandler = sizeHandler
        self.sectionItemsNumberHandler = sectionItemsNumberHandler
        self.makeSectionItemHandler = makeSectionItemHandler
    }
}

// MARK: - SectionItemsProvider

extension LazySectionItemsProvider: SectionItemsProvider {

    public subscript(index: Int) -> CollectionViewSectionItem? {
        get {
            if let sectionItem = sectionItemsDictionary[index] {
                return sectionItem
            }
            let sectionItem = makeSectionItemHandler(index)
            sectionItem?.collectionView = collectionView
            sectionItem?.index = index
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

            cellItem.sectionItem = sectionItem
            cellItem.indexPath = indexPath
            cellItem.collectionView = collectionView
            collectionView?.registerCell(with: cellItem.reuseType)
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

    var numberOfSectionItems: Int {
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

    func insert(_ sectionItem: CollectionViewSectionItem, at index: Int) {
        for key in sectionItemsDictionary.keys.sorted(by: >) where key >= index {
            self[key + 1] = sectionItems[key]
        }
        self[index] = sectionItem
    }

    func insert(_ sectionItems: [CollectionViewSectionItem], at index: Int) {
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
}
