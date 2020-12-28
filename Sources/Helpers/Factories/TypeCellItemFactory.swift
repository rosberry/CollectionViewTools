//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class TypeCellItemFactory<Object: Equatable, View: UICollectionViewCell> {

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Int: the index of an object in the provided array
    ///    - Any: the object associated with a cell item
    public var initializationHandler: ((Int, Object) -> [CollectionViewCellItem?])?

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
    public var cellItemConfigurationHandler: ((Int, TypeCollectionViewCellItem<Object, View>) -> Void)?

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: the cell that should be configured
    ///    - CollectionViewCellItem: the cell item that performs a cell configuration
    public var cellConfigurationHandler: ((View, TypeCollectionViewCellItem<Object, View>) -> Void)?

    public init() {
    }

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    public func makeCellItems(array: [Object]) -> [CollectionViewCellItem] {
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
    public func makeUniversalCellItem(object: Object, index: Int) -> TypeCollectionViewCellItem<Object, View> {
        let cellItem = makeUniversalCellItem(object: object)
        cellItemConfigurationHandler?(index, cellItem)
        return cellItem
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    ///    - configure: a cell configuration handler
    ///    - size: a cell size configuration handler
    public func makeCellItem(object: Object,
                             configure configurationHandler: @escaping (View) -> Void,
                             size sizeConfigurationHandler: @escaping (UICollectionView, CollectionViewSectionItem) -> CGSize) -> CollectionViewCellItem {
        let cellItem = TypeCollectionViewCellItem<Object, View>(object: object)
        cellItem.configurationHandler = configurationHandler
        cellItem.sizeConfigurationHandler = sizeConfigurationHandler
        return cellItem
    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func makeUniversalCellItem(object: Object) -> TypeCollectionViewCellItem<Object, View> {
        let cellItem = TypeCollectionViewCellItem<Object, View>(object: object)
        cellItem.configurationHandler = { [weak self] cell in
            guard let self = self else {
                return
            }
            guard let configurationHandler = self.cellConfigurationHandler else {
                fatalError("configurationHandler property for the CellItemFactory should be assigned before")
            }
            configurationHandler(cell, cellItem)
        }
        cellItem.sizeConfigurationHandler = { [weak self, weak cellItem] (collectionView, sectionItem) -> CGSize in
            guard let self = self else {
                return .zero
            }
            guard let sizeConfigurationHandler = self.sizeConfigurationHandler else {
                fatalError("sizeConfigurationHandler property for the CellItemFactory should be assigned before")
            }
            return sizeConfigurationHandler(cellItem?.object ?? object, collectionView, sectionItem)
        }
        return cellItem
    }
}

extension TypeCellItemFactory: CellItemFactory {

    public func makeCellItem(object: Any) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return makeUniversalCellItem(object: object)
    }

    public func makeCellItems(array: [Any]) -> [CollectionViewCellItem] {
        if let array = array as? [Object] {
            return makeCellItems(array: array)
        }
        return []
    }

    public func makeCellItems(object: Any, index: Int) -> [CollectionViewCellItem] {
        if let object = object as? Object {
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

    public func makeCellItem(object: Any, index: Int) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return makeUniversalCellItem(object: object, index: index)
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
