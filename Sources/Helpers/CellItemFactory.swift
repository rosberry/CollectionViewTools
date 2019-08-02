//
//  CollectionViewCellConfigurator.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public final class UniversalCollectionViewCellItem<T: UICollectionViewCell>: CollectionViewCellItem {

    public let reuseType = ReuseType.class(T.self)
    
    public var context = [String: Any]()
    
    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: collection view cell that should be configured
    public var configurationHandler: ((T) -> Void)?
    
    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((UICollectionView, CollectionViewSectionItem) -> CGSize)?
    
    public init() {
    }

    public func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? T else {
            return
        }
        configurationHandler?(cell)
    }
    
    public func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return sizeConfigurationHandler?(collectionView, sectionItem) ?? .zero
    }
}

public protocol CellItemFactory {
    
    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    func makeCellItems(for array: [Any]) -> [CollectionViewCellItem]
    
    /// Returns a cell items for associated object
    ///
    /// - Parameters:
    ///    - object: an object associated with cell item
    ///    - index: the position of the object in the array
    func makeCellItems(for object: Any, at index: Int) -> [CollectionViewCellItem]
    
    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    func join(_ factory: CellItemFactory) -> CellItemFactory
    
    /// Defines a unique identifier associated with a specific type of factory
    var hashKey: String? { get }
}

public class AssociatedCellItemFactory<U, T: UICollectionViewCell> {
    
    public init() {
    }
    
    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((U, UICollectionView, CollectionViewSectionItem) -> CGSize)?
    
    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Int: the index path of an object in the provided array
    ///    - Any: the object associated with a cell item
    public var initializationHandler: ((Int, U) -> [CollectionViewCellItem?])?
    
    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - CollectionViewCellItem: a cell item that should be cofigured
    public var cellItemConfigurationHandler: ((Int, U, CollectionViewCellItem) -> Void)?
    
    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - UICollectionViewCell: the cell that should be configured
    ///    - CollectionViewCellItem: the cell item that performs a cell configuration
    public var cellConfigurationHandler: ((U, T, CollectionViewCellItem) -> Void)?
    
    private var subfactories = [String: Any]()
    
    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    public func makeCellItems(for array: [U]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        array.enumerated().forEach { index, object in
            cellItems.append(contentsOf: makeCellItems(for: object, at: index))
        }
        return cellItems
    }
    
    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - U: an object to create a cell item for it
    ///    - Int: the index of the object in the array
    public func makeUniversalCellItem(for object: U, at index: Int) -> CollectionViewCellItem {
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
    public func makeCellItems(for array: [Any]) -> [CollectionViewCellItem] {
        if let array = array as? [U] {
            return makeCellItems(for: array)
        }
        return []
    }
    
    public func makeCellItems(for object: Any, at index: Int) -> [CollectionViewCellItem] {
        if let object = object as? U {
            if let initializationHandler = self.initializationHandler {
                var cellItems = [CollectionViewCellItem]()
                initializationHandler(index, object).forEach { cellItem in
                    if let cellItem = cellItem {
                        cellItems.append(cellItem)
                    }
                }
                return cellItems
            }
            else {
                return [makeUniversalCellItem(for: object, at: index)]
            }
        }
        return []
    }
    
    public func join(_ factory: CellItemFactory) -> CellItemFactory {
        let complexFactory = ComplexCellItemFactory()
        complexFactory.join(self)
        complexFactory.join(factory)
        return complexFactory
    }
    
    public var hashKey: String? {
        return String(describing: U.self)
    }
}

public class ComplexCellItemFactory: CellItemFactory {
    
    private var factories = [String: CellItemFactory]()
    
    public init() {
    }

    public func makeCellItems(for array: [Any]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        array.enumerated().forEach { index, object in
            if let factory = factories[String(describing: type(of: object))] {
                cellItems.append(contentsOf: factory.makeCellItems(for: object, at: index))
            }
        }
        return cellItems
    }
    
    public func makeCellItems(for object: Any, at index: Int) -> [CollectionViewCellItem] {
        if let factory = factories[String(describing: type(of: object))] {
            return factory.makeCellItems(for: object, at: index)
        }
        return []
    }
    
    @discardableResult
    public func join(_ factory: CellItemFactory) -> CellItemFactory {
        if let factory = factory as? ComplexCellItemFactory {
            factory.factories.forEach { (key, value) in
                factories[key] = value
            }
        }
        else if let key = factory.hashKey {
            factories[key] = factory
        }
        return self
    }
    
    /// Removes a factory from complex hierarchy
    ///
    /// - Parameters:
    ///     - factory: a factory that should be removed
    public func unjoin(_ factory: CellItemFactory) {
        if let key = factory.hashKey {
            factories.removeValue(forKey: key)
        }
        else if let factory = factory as? ComplexCellItemFactory {
            factory.factories.forEach { (key, _) in
                factories.removeValue(forKey: key)
            }
        }
    }
    
    public var hashKey: String? {
        return nil
    }
}
