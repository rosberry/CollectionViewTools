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

private protocol CellItemMaker {
    func makeCellItems(for array: [Any]) -> [CollectionViewCellItem]
}


public class CellItemFactory<U, T: UICollectionViewCell> {
    
    
    public var sizeConfigurationHandler: CellItemSizeConfigurationHandler<U, T>?
    public var initializationHandler: ((U) -> [CollectionViewCellItem?])?
    public var cellItemConfigurationHandler: ((U, CollectionViewCellItem) -> Void)?
    public var cellConfigurationHandler: CellItemConfigurationHandler<U, T>?
    
    private var subfactories = [String: Any]()
    
    public init() {
    }
    
    public func makeCellItems(for array: [U]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        array.forEach { object in
            if let initializationHandler = self.initializationHandler {
                initializationHandler(object).forEach { cellItem in
                    if let cellItem = cellItem {
                        cellItems.append(cellItem)
                    }
                }
            }
            else {
                cellItems.append(makeUniversalCellItem(for: object))
            }
        }
        return cellItems
    }
    
    public func makeUniversalCellItem(for object: U) -> CollectionViewCellItem {
        let cellItem = UniversalCollectionViewCellItem<T>()
        cellItem.configurationHandler = { [weak self] cell in
            guard let self = self else {
                return
            }
            guard let configurationHandler = self.cellConfigurationHandler else {
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
        cellItemConfigurationHandler?(object, cellItem)
        return cellItem
    }

    public func makeCellItem(configure configurationHandler: @escaping (T) -> Void,
                             size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> CollectionViewCellItem {
        let cellItem = UniversalCollectionViewCellItem<T>()
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }
}

extension CellItemFactory: CellItemMaker {
    public func makeCellItems(for array: [Any]) -> [CollectionViewCellItem] {
        if let array = array as? [U] {
            return makeCellItems(for: array)
        }
        return []
    }
}

public class ComplexCellItemFactory: CellItemMaker {
    
    private var factories = [String: CellItemMaker]()
    
    public init() {
    }
    
    public func add<U: Any, T: UICollectionViewCell>(_ factory: CellItemFactory<U, T>) {
        factories[String(describing: U.self)] = factory
    }
    
    public func remove<U: Any, T: UICollectionViewCell>(_ factory: CellItemFactory<U, T>) {
        factories.removeValue(forKey: String(describing: U.self))
    }
    
    public func makeCellItems(for array: [Any]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        array.forEach { object in
            if let factory = factories[String(describing: type(of: object))] {
                cellItems.append(contentsOf: factory.makeCellItems(for: [object]))
            }
        }
        return cellItems
    }
}
