//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class LazyFactorySectionItemsProvider: LazySectionItemsProvider {
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
