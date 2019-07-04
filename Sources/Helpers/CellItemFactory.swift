//
//  CollectionViewCellConfigurator.swift
//  CollectionViewTools
//
//  Created by Nick Tyunin on 04/07/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public typealias CellItemConfigurationHandler<U,T> = (U, T, CollectionViewCellItem) -> Void
public typealias CellItemSizeConfigurationHandler<U,T> = (U, UICollectionView, CollectionViewSectionItem) -> CGSize

internal class UniversalCollectionViewCellItem<T: UICollectionViewCell>: CollectionViewCellItem {

    let reuseType = ReuseType.class(T.self)
    var configurationHandler: ((T) -> Void)?
    var sizeConfigurationHandler: ((UICollectionView, CollectionViewSectionItem) -> CGSize)?

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? T else {
            return
        }
        configurationHandler?(cell)
    }
    
    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return sizeConfigurationHandler?(collectionView, sectionItem) ?? .zero
    }
}

public class CellItemFactory<U: Any, T: UICollectionViewCell> {
    
    public var configurationHandler: CellItemConfigurationHandler<U, T>?
    public var sizeConfigurationHandler: CellItemSizeConfigurationHandler<U, T>?
    
    public init() {
    }
    
    public func makeCellItems(for array: [U]) -> [CollectionViewCellItem] {
        return array.map { object in
            let cellItem = UniversalCollectionViewCellItem<T>()
            cellItem.configurationHandler = { [weak self] cell in
                guard let self = self else {
                    return
                }
                guard let configurationHandler = self.configurationHandler else {
                    fatalError("configurationHandler property for the CellItemFactory should be assigned before")
                }
                configurationHandler(object, cell, cellItem)
            }
            cellItem.sizeConfigurationHandler = { [weak self] (collectionView, sectionItem) -> CGSize in
                guard let self = self else {
                    return .zero
                }
                guard let sizeConfigurationHandler = self.sizeConfigurationHandler else {
                    fatalError("sizeConfigurationHandler property for the CellItemFactory should be assigned before")
                }
                return sizeConfigurationHandler(object, collectionView, sectionItem)
            }
            return cellItem
        }
    }

    public func makeCellItem(configure configurationHandler: @escaping (T) -> Void,
                             size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> CollectionViewCellItem {
        let cellItem = UniversalCollectionViewCellItem<T>()
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }
}
