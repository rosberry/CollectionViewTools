//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public protocol CellItemFactory {

    /// Basically, you can configure cellItemsFactory to return any amount of cellItems associated with one object.
    /// But in the case of lazy access we should stricly associate indexPath and cellItem. This method does not create
    /// additional decorators cellItems to provide this association
    ///
    /// - Parameters:
    ///
    ///    - object: an object to create a cell item for it
    func makeCellItem(object: Any) -> CollectionViewCellItem?

    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    func makeCellItems(objects: [Any]) -> [CollectionViewCellItem]

    /// Returns a cell items for associated object
    ///
    /// - Parameters:
    ///    - object: an object associated with cell item
    func makeCellItems(object: Any) -> [CollectionViewCellItem]

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    func factory(byJoining factory: CellItemFactory) -> CellItemFactory

    /// Defines a unique identifier associated with a specific type of factory
    var hashKey: String? { get }
}
