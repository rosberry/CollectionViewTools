//
//  AssociatedCellItemFactory.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class AssociatedCellItemFactory<U, T: UICollectionViewCell> {

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Int: the index path of an object in the provided array
    ///    - Any: the object associated with a cell item
    public var initializationHandler: ((Int, U) -> [CollectionViewCellItem?])?
    
    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((U, UICollectionView, CollectionViewSectionItem) -> CGSize)?
    
    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - CollectionViewCellItem: a cell item that should be cofigured
    public var cellItemConfigurationHandler: ((Int, U, UniversalCollectionViewCellItem<T>) -> Void)?
    
    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - UICollectionViewCell: the cell that should be configured
    ///    - CollectionViewCellItem: the cell item that performs a cell configuration
    public var cellConfigurationHandler: ((U, T, UniversalCollectionViewCellItem<T>) -> Void)?

    public var isEqualHandler: ((UniversalCollectionViewCellItem<T>, UniversalCollectionViewCellItem<T>) -> Bool)?
    
    public init() {
    }
    
    
    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    public func makeCellItems(array: [U]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        for index in 0..<array.count {
            let object = array[index]
            cellItems.append(contentsOf: makeCellItems(object: object, index: index))
        }
        return cellItems
    }
    
    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    ///    - index: the index of the object in the array
    public func makeUniversalCellItem(object: U, index: Int) -> UniversalCollectionViewCellItem<T> {
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
        cellItem.isEqualHandler = { [weak self] otherCellItem in
            guard let handler = self?.isEqualHandler else {
                return true
            }
            return handler(cellItem, otherCellItem)
        }
        cellItemConfigurationHandler?(index, object, cellItem)
        return cellItem
    }
    
    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - configure: a cell configuration handler
    ///    - size: a cell size configuration handler
    public func makeCellItem(configure configurationHandler: @escaping (T) -> Void,
                             size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> CollectionViewCellItem {
        let cellItem = UniversalCollectionViewCellItem<T>()
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }
}

extension AssociatedCellItemFactory: CellItemFactory {
    public func makeCellItems(array: [Any]) -> [CollectionViewCellItem] {
        if let array = array as? [U] {
            return makeCellItems(array: array)
        }
        return []
    }
    
    public func makeCellItems(object: Any, index: Int) -> [CollectionViewCellItem] {
        if let object = object as? U {
            if let initializationHandler = self.initializationHandler {
                return initializationHandler(index, object).compactMap { cellItem in
                    cellItem
                }
            }
            else {
                return [makeUniversalCellItem(object: object, index: index)]
            }
        }
        return []
    }
    
    public func factory(byJoining factory: CellItemFactory) -> CellItemFactory {
        let complexFactory = ComplexCellItemFactory()
        complexFactory.factory(byJoining: self)
        complexFactory.factory(byJoining: factory)
        return complexFactory
    }
    
    public var hashKey: String? {
        return String(describing: U.self)
    }
}
