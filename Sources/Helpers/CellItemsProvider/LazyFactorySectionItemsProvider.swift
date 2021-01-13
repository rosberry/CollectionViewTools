//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class LazyComplexFactorySectionItemsProvider: LazySectionItemsProvider {
    /// `LazyFactorySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - factory: complex factory to configure cell
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(factory: ComplexCellItemsFactory,
                sectionItemsNumberHandler: @escaping () -> Int = {
                    1
                },
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                objectHandler: @escaping (IndexPath) -> Any?) {

        super.init(
            sectionItemsNumberHandler: sectionItemsNumberHandler,
            cellItemsNumberHandler: cellItemsNumberHandler,
            sizeHandler: sizeHandler,
            makeSectionItemHandler: makeSectionItemHandler,
            makeCellItemHandler: { indexPath in
               guard let object = objectHandler(indexPath) else {
                   return nil
               }
               return factory.makeCellItem(object: object)
            }
        )
    }
}

open class LazyFactorySectionItemsProvider<Object: CanBeDiff, Cell: UICollectionViewCell>: LazySectionItemsProvider {
    /// `LazyFactorySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - cellConfigurationHandler: block to configure cell according it cell item
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public convenience init(sectionItemsNumberHandler: @escaping () -> Int = {
                    1
                },
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                cellConfigurationHandler: ((Cell, UniversalCollectionViewCellItem<Object, Cell>) -> Void)?,
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                objectHandler: @escaping (IndexPath) -> Object?) {

        let factory = CellItemsFactory<Object, Cell>()
        factory.cellConfigurationHandler = cellConfigurationHandler

        self.init(
            factory: factory,
            sectionItemsNumberHandler: sectionItemsNumberHandler,
            cellItemsNumberHandler: cellItemsNumberHandler,
            makeSectionItemHandler: makeSectionItemHandler,
            sizeHandler: sizeHandler,
            objectHandler: objectHandler
        )
    }

    /// `LazyFactorySectionItemsProvider` initializer
    ///
    /// - Parameters:
    ///    - factory: cell items factory to generate cells
    ///    - sectionItemsNumberHandler: block that returns number of sections, returns 1 by default
    ///    - cellItemsNumberHandler: block that returns number of items in section
    ///    - makeSectionItemHandler: block that returns section item to lazy load cell items in it, `GeneralCollectionViewDiffSectionItem` by default
    ///    - sizeHandler: block that returns size of cell at index path
    ///    - objectHandler: block that returns object at index path to associate it with cell item
    public init(factory: CellItemsFactory<Object, Cell>,
                sectionItemsNumberHandler: @escaping () -> Int = {
                    1
                },
                cellItemsNumberHandler: @escaping (Int) -> Int,
                makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem? = { _ in
                    GeneralCollectionViewDiffSectionItem()
                },
                sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
                objectHandler: @escaping (IndexPath) -> Object?) {

        super.init(
            sectionItemsNumberHandler: sectionItemsNumberHandler,
            cellItemsNumberHandler: cellItemsNumberHandler,
            sizeHandler: sizeHandler,
            makeSectionItemHandler: makeSectionItemHandler,
            makeCellItemHandler: { indexPath in
               guard let object = objectHandler(indexPath) else {
                   return nil
               }
               return factory.makeCellItem(object: object)
            }
        )
    }
}
