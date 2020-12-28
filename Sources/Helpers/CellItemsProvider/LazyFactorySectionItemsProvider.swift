//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class LazyFactorySectionItemsProvider: LazySectionItemsProvider {

    /// `LazyFactorySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - factory: the instance of `CellItemFactory` to generate cell items
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(factory: CellItemFactory,
                sectionItemsNumberHandler: @escaping () -> Int = {
                    1
                },
                cellItemsNumberHandler: @escaping (Int) -> Int,
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                objectHandler: @escaping (IndexPath) -> Any?) {

        super.init(sectionItemsNumberHandler: sectionItemsNumberHandler,
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: makeSectionItemHandler,
                   makeCellItemHandler: { indexPath in
                       guard let object = objectHandler(indexPath) else {
                           return nil
                       }
                       let cellItem = factory.makeCellItem(object: object, index: indexPath.row)
                       return cellItem
                   })
    }
}

open class LazyAssociatedFactorySectionItemsProvider<U: GenericDiffItem, T: UICollectionViewCell>: LazySectionItemsProvider {
    /// `LazyFactorySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - cellConfigurationHandler: block to configure cell according it cell item
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(sectionItemsNumberHandler: @escaping () -> Int = {
        1
    },
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                cellConfigurationHandler: ((T, UniversalCollectionViewCellItem<U, T>) -> Void)?,
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                objectHandler: @escaping (IndexPath) -> Any?) {

        let factory = AssociatedCellItemFactory<U, T>()
        factory.cellConfigurationHandler = cellConfigurationHandler

        super.init(sectionItemsNumberHandler: sectionItemsNumberHandler,
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: makeSectionItemHandler,
                   makeCellItemHandler: { indexPath in
                       guard let object = objectHandler(indexPath) else {
                           return nil
                       }
                       return factory.makeCellItem(object: object, index: indexPath.row)
                   })
    }
}

open class LazyAssociatedFactoryTypeSectionItemsProvider<Object: Equatable, View: UICollectionViewCell>: LazySectionItemsProvider {
    public init(factory: TypeCellItemFactory<Object, View>,
                sectionItemsNumberHandler: @autoclosure @escaping () -> Int = 1,
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                objectHandler: @escaping (IndexPath) -> Any?) {

        super.init(sectionItemsNumberHandler: sectionItemsNumberHandler,
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: { _, _ in .zero },
                   makeSectionItemHandler: makeSectionItemHandler,
                   makeCellItemHandler: { indexPath in
                       guard let object = objectHandler(indexPath) else {
                           return nil
                       }
                       let cellItem = factory.makeCellItem(object: object, index: indexPath.row)
                       return cellItem
                   })
        self.sizeHandler = { indexPath, collection in
            guard let sectionItem = self[indexPath.row],
                  let cellItem = self[indexPath] as? TypeCollectionViewCellItem<Object, View> else {
                return .zero
            }
            return factory.sizeConfigurationHandler?(cellItem.object, collection, sectionItem) ?? .zero

        }
    }
}
