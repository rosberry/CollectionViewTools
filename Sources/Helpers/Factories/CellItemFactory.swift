//
//  AssociatedCellItemFactory.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class CellItemsFactory<Object: CanBeDiff, Cell: UICollectionViewCell> {

    public typealias CellItem = UniversalCollectionViewCellItem<Object, Cell>

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Int: the index of an object in the provided array
    ///    - U: the object associated with a cell item
    public var initializationHandler: ((Object) -> [CollectionViewCellItem?])?

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - Any: the object associated with a cell item
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((Object, UICollectionView, CollectionViewSectionItem) -> CGSize)?

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - Int: the index of an object in the provided array
    ///    - CollectionViewCellItem: a cell item that should be cofigured
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: the cell that should be configured
    ///    - CollectionViewCellItem: the cell item that performs a cell configuration
    public var cellConfigurationHandler: ((Cell, CellItem) -> Void)?

    public init() {
    }

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - objects: an array of objects to create cell items for them
    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        objects.flatMap(makeCellItems)
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it 
    ///    - configure: a cell configuration handler
    ///    - size: a cell size configuration handler
    public func makeCellItem(object: Object,
                             configure configurationHandler: @escaping (Cell) -> Void,
                             size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> CollectionViewCellItem {
        let cellItem = CellItem(object: object)
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }

    /// Returns a cell items for associated object
    ///
    /// - Parameters:
    ///    - object: an object associated with cell item
    public func makeCellItems(object: Object) -> [CollectionViewCellItem] {
       if let initializationHandler = self.initializationHandler {
           return initializationHandler(object).compactMap { cellItem in
               cellItem
           }
       }
       else {
           return [makeUniversalCellItem(object: object)]
       }
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func makeUniversalCellItem<ConcreteCellItem: CellItem>(object: Object) -> ConcreteCellItem {
        let cellItem = ConcreteCellItem(object: object)
        cellItem.configurationHandler = { [weak self] cell in
            guard let self = self else {
                return
            }
            guard let configurationHandler = self.cellConfigurationHandler else {
                fatalError("configurationHandler property for the CellItemFactory should be assigned before")
            }
            configurationHandler(cell, cellItem)
        }
        if let sizeConfigurationHandler = self.sizeConfigurationHandler {
            cellItem.sizeConfigurationHandler = { [weak cellItem] (collectionView, sectionItem) -> CGSize in
                return sizeConfigurationHandler(cellItem?.object ?? object, collectionView, sectionItem)
            }
        }

        cellItemConfigurationHandler?(cellItem)
        return cellItem
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: CanBeDiff, Cell: UICollectionViewCell>(byJoining factory: CellItemsFactory<Object, Cell>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    public func factory<Object: CanBeDiff, View: UIView>(byJoining factory: ViewCellItemsFactory<Object, View>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory.factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory(byJoining factory: ComplexCellItemsFactory) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }
}