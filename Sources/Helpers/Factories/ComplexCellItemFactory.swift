//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class ComplexCellItemFactory: CellItemFactory {

    private var factories = [String: CellItemFactory]()

    public init() {
    }

    public func makeCellItems(array: [Any]) -> [CollectionViewCellItem] {
        var cellItems = [CollectionViewCellItem]()
        array.enumerated().forEach { index, object in
            if let factory = factories[String(describing: type(of: object))] {
                cellItems.append(contentsOf: factory.makeCellItems(object: object, index: index))
            }
        }
        return cellItems
    }

    public func makeCellItem(object: Any, index: Int) -> CollectionViewCellItem? {
        if let factory = factories[String(describing: type(of: object))] {
            return factory.makeCellItem(object: object, index: index)
        }
        return nil
    }

    public func makeCellItems(object: Any, index: Int) -> [CollectionViewCellItem] {
        if let factory = factories[String(describing: type(of: object))] {
            return factory.makeCellItems(object: object, index: index)
        }
        return []
    }

    public func makeCellItem(object: Any) -> CollectionViewCellItem? {
        if let factory = factories[String(describing: type(of: object))] {
            return factory.makeCellItem(object: object)
        }
        return nil
    }

    @discardableResult
    public func factory(byJoining factory: CellItemFactory) -> CellItemFactory {
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
    public func unjoin(factory: CellItemFactory) {
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
