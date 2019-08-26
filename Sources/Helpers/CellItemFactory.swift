//
//  CellItemFactory.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public protocol CellItemFactory {
    
    /// Returns an array of cell items
    ///
    /// - Parameters:
    ///    - array: an array of objects to create cell items for them
    func makeCellItems(array: [Any]) -> [CollectionViewCellItem]
    
    /// Returns a cell items for associated object
    ///
    /// - Parameters:
    ///    - object: an object associated with cell item
    ///    - index: the position of the object in the array
    func makeCellItems(object: Any, index: Int) -> [CollectionViewCellItem]
    
    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    @discardableResult
    func join(_ factory: CellItemFactory) -> CellItemFactory
    
    /// Defines a unique identifier associated with a specific type of factory
    var hashKey: String? { get }
}
