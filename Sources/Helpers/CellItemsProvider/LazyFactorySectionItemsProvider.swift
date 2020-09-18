//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class LazyFactorySectionItemsProvider: LazySectionItemsProvider {
    init(factory: CellItemFactory,
         sectionItemsNumberHandler: @escaping () -> Int = {
            1
         },
         cellItemsNumberHandler: @escaping (Int) -> Int,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
         makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem?,
         objectHandler: @escaping (IndexPath) -> Any) {
        super.init(reuseTypes: factory.fetchReuseTypes(),
                   sectionItemsNumberHandler: sectionItemsNumberHandler,
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: makeSectionItemHandler,
                   makeCellItemHandler: { indexPath in
            factory.makeCellItem(object: objectHandler(indexPath), index: indexPath.row)
        })
    }

    init(factory: CellItemFactory,
         reusableViewItems: [CollectionViewReusableViewItem] = [],
         cellItemsNumberHandler: @escaping (Int) -> Int,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
         objectHandler: @escaping (IndexPath) -> Any) {
        super.init(reuseTypes: factory.fetchReuseTypes(),
                   sectionItemsNumberHandler: {
            1
        },
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: { _ in
            GeneralCollectionViewDiffSectionItem(cellItems: [],
            reusableViewItems: reusableViewItems)
        },
                   makeCellItemHandler: { indexPath in
            factory.makeCellItem(object: objectHandler(indexPath), index: indexPath.row)
        })
    }
}

open class LazyAssociatedFactorySectionItemsProvider<U, T: UICollectionViewCell>: LazySectionItemsProvider {
    init(reuseTypes: [ReuseType] = [],
         sectionItemsNumberHandler: @escaping () -> Int = {
            1
        },
         cellItemsNumberHandler: @escaping (Int) -> Int,
         makeSectionItemHandler: @escaping (Int) -> CollectionViewSectionItem?,
         cellConfigurationHandler: ((U, T, UniversalCollectionViewCellItem<T>) -> Void)?,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
         objectHandler: @escaping (IndexPath) -> Any) {
        let factory = AssociatedCellItemFactory<U, T>()
        factory.cellConfigurationHandler = cellConfigurationHandler
        super.init(reuseTypes: reuseTypes,
                   sectionItemsNumberHandler: sectionItemsNumberHandler,
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: makeSectionItemHandler,
                   makeCellItemHandler: { indexPath in
            factory.makeCellItem(object: objectHandler(indexPath), index: indexPath.row)
        })
        self.reuseTypes.append(contentsOf: factory.fetchReuseTypes())
    }

    init(reuseTypes: [ReuseType] = [],
         reusableViewItems: [CollectionViewReusableViewItem] = [],
         cellItemsNumberHandler: @escaping (Int) -> Int,
         cellConfigurationHandler: ((U, T, UniversalCollectionViewCellItem<T>) -> Void)?,
         sizeHandler: @escaping (IndexPath, UICollectionView) -> CGSize,
         objectHandler: @escaping (IndexPath) -> Any) {
        let factory = AssociatedCellItemFactory<U, T>()
        factory.cellConfigurationHandler = cellConfigurationHandler
        super.init(reuseTypes: reuseTypes,
                   sectionItemsNumberHandler: {
                       1
                   },
                   cellItemsNumberHandler: cellItemsNumberHandler,
                   sizeHandler: sizeHandler,
                   makeSectionItemHandler: { _ in
            GeneralCollectionViewDiffSectionItem(cellItems: [], reusableViewItems: reusableViewItems)
        },
                   makeCellItemHandler: { indexPath in
            factory.makeCellItem(object: objectHandler(indexPath), index: indexPath.row)
        })
        self.reuseTypes.append(contentsOf: factory.fetchReuseTypes())
    }
}
