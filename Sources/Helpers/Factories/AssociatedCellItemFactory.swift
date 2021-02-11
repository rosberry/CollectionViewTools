//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class AssociatedCellItemFactory<Object: GenericDiffItem, Cell: UICollectionViewCell> {

    public typealias CellItem = UniversalCollectionViewCellItem<Object, Cell>

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    public var initializationHandler: ((Object) -> [CollectionViewCellItem?])?

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - UICollectionView: collection view where cell should be placed.
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed.
    ///    - CellItem: generated or defined in `initializationHandler` universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var sizeConfigurationHandler: ((UICollectionView, CollectionViewSectionItem, CellItem) -> CGSize)?

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - CellItem: generated or defined in `initializationHandler` universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - Cell: the cell that should be configured
    ///    - CellItem: a cell item that should be cofigured. Associated object can be retrieved via `cellItem.object`.
    public var cellConfigurationHandler: ((Cell, CellItem) -> Void)?

    public init() {
    }

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - objects: an array of objects to create cell items for them
    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        for index in 0..<objects.count {
            let object = objects[index]
            cellItems.append(contentsOf: makeCellItems(object: object))
        }
        return cellItems
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
                guard let cellItem = cellItem else {
                    return .zero
                }
                return sizeConfigurationHandler(collectionView, sectionItem, cellItem)
            }
        }

        cellItemConfigurationHandler?(cellItem)
        return cellItem
    }
}

extension AssociatedCellItemFactory: CellItemFactory {

    public func makeCellItem(object: Any) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return makeUniversalCellItem(object: object)
    }

    public func makeCellItems(objects: [Any]) -> [CollectionViewCellItem] {
        if let objects = objects as? [Object] {
            return makeCellItems(objects: objects)
        }
        return []
    }

    public func makeCellItems(object: Any) -> [CollectionViewCellItem] {
        if let object = object as? Object {
            if let initializationHandler = self.initializationHandler {
                return initializationHandler(object).compactMap { cellItem in
                    cellItem
                }
            }
            else {
                return [makeUniversalCellItem(object: object)]
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
        return String(describing: Object.self)
    }
}
