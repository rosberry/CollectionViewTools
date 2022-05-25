//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class CellItemsFactory<Object: DiffCompatible, Cell: UICollectionViewCell> {

    public typealias CellItem = UniversalCollectionViewCellItem<Object, Cell>

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((Object, UICollectionView, CollectionViewSectionItem) -> CGSize)?

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: the cell that should be configured
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var cellConfigurationHandler: ((Cell, CellItem) -> Void)?

    public init() {
    }

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - objects: an array of objects to create cell items for them
    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        objects.compactMap(makeCellItem)
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    ///    - configure: a cell configuration handler
    ///    - size: a cell size configuration handler
    public func makeCellItem<ConcreteCellItem: CellItem>(object: Object,
                                                         configure configurationHandler: @escaping (Cell) -> Void,
                                                         size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> ConcreteCellItem {
        let cellItem = ConcreteCellItem(object: object)
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func makeCellItem<ConcreteCellItem: CellItem>(object: Object) -> ConcreteCellItem {
        let cellItem = ConcreteCellItem(object: object)
        setup(cellItem: cellItem, object: object)
        return cellItem
    }

    /// Assigns cell configuration and size configuration handlers to factory handlers
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func setup<ConcreteCellItem: CellItem>(cellItem: ConcreteCellItem, object: Object) {
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
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: DiffCompatible, Cell: UICollectionViewCell>(byJoining factory: CellItemsFactory<Object, Cell>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    public func factory<Object: DiffCompatible, View: UIView>(byJoining factory: ViewCellItemsFactory<Object, View>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory(byJoining factory: ComplexCellItemsFactory) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }
}
