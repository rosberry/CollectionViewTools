//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class ComplexCellItemsFactory {

    private var factories = [String: AnyCellItemsFactory]()

    public init() {
    }

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - objects: an array of objects to create cell items for them
    public func makeCellItems(objects: [Any]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        objects.forEach { object in
            if let factory = factories[String(describing: type(of: object))],
               let cellItem = factory.makeCellItem(object: object) {
                cellItems.append(cellItem)
            }
        }
        return cellItems
    }

    /// Returns an instance of `CollectionViewCellItem`
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func makeCellItem(object: Any) -> CollectionViewCellItem? {
        if let factory = factories[String(describing: type(of: object))] {
            return factory.makeCellItem(object: object)
        }
        return nil
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    public func factory<Object: DiffCompatible, Cell: UICollectionViewCell>(byJoining factory: CellItemsFactory<Object, Cell>) -> ComplexCellItemsFactory {
        let factory = AnyAssociatedCellItemsFactory(factory)
        if let key = factory.hashKey {
            factories[key] = factory
        }
        return self
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    public func factory<Object: DiffCompatible, View: UIView>(byJoining factory: ViewCellItemsFactory<Object, View>) -> ComplexCellItemsFactory {
        let factory = AnyViewCellItemsFactory(factory)
        if let key = factory.hashKey {
            factories[key] = factory
        }
        return self
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    public func factory(byJoining factory: ComplexCellItemsFactory) -> ComplexCellItemsFactory {
        factory.factories.forEach { key, value in
            factories[key] = value
        }
        return self
    }

    /// Removes a factory from complex hierarchy
    ///
    /// - Parameters:
    ///     - factory: a factory that should be removed
    public func unjoin<Object: DiffCompatible, Cell: UICollectionViewCell>(factory: CellItemsFactory<Object, Cell>) {
        factories.removeValue(forKey: String(describing: Object.self))
    }

    /// Removes a factory from complex hierarchy
    ///
    /// - Parameters:
    ///     - factory: a factory that should be removed
    public func unjoin(factory: ComplexCellItemsFactory) {
        factory.factories.forEach { key, _ in
            factories.removeValue(forKey: key)
        }
    }
}
