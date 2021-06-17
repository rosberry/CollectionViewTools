//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class ViewCellItemsFactory<Object: DiffCompatible, View: UIView> {

    public typealias Cell = CollectionViewViewCell<View>
    public typealias CellItem = CollectionViewViewCellItem<Object, View>
    typealias Factory = CellItemsFactory<Object, Cell>

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to provide size types for cellItem
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var sizeTypesConfigurationHandler: ((CellItem) -> SizeTypes)?

    /// Set this handler to provide specific an instance of `View`
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var viewInitializer: ((CellItem) -> View)? = { _ in
        .init()
    }

    // Set this handler to perform primary configuration of`View` after it will be instantiated
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.
    public var viewInitialConfigurationHandler: ((View, CellItem) -> Void)?

    // Set this handler to perform view configuration on collection view cell reloading
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item. Associated object can be retrieved via `cellItem.object`.    
    public var viewConfigurationHandler: ((View, CellItem) -> Void)?

    private lazy var sizeCell: CollectionViewViewCell<View> = {
        let cell = CollectionViewViewCell<View>()
        cell.bounds.size = .init(width: 1000, height: 1000)
        return cell
    }()

    private(set) lazy var factory: Factory = {
        let factory = Factory()

        factory.cellItemConfigurationHandler = { [weak self] cellItem in
            guard let cellItem = cellItem as? CellItem else {
                return
            }
            cellItem.sizeTypes = self?.sizeTypesConfigurationHandler?(cellItem)
            cellItem.sizeCell = self?.sizeCell
            self?.cellItemConfigurationHandler?(cellItem)
        }

        factory.cellConfigurationHandler = { [weak self] cell, cellItem in
            guard let self = self,
                  let cellItem = cellItem as? CellItem else {
                return
            }
            if let view = cell.view {
                self.viewConfigurationHandler?(view, cellItem)
            }
            else {
                let view = self.viewInitializer?(cellItem) ?? View()
                self.viewInitialConfigurationHandler?(view, cellItem)
                cell.view = view
                self.viewConfigurationHandler?(view, cellItem)
            }
        }

        return factory
    }()

    public init() {

    }

    /// Returns an instance of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - object: an object to create a cell item for it
    public func makeCellItem(object: Object) -> CellItem {
        factory.makeCellItem(object: object)
    }

    /// Returns an instances of `UniversalCollectionViewCellItem` and associates provided handlers with them
    ///
    /// - Parameters:
    ///    - objects: an array of object to create a cell item for it
    public func makeCellItems(objects: [Object]) -> [CellItem] {
        objects.map { object in
            makeCellItem(object: object)
        }
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: DiffCompatible, Cell: UICollectionViewCell>(byJoining factory: CellItemsFactory<Object, Cell>) -> ComplexCellItemsFactory {
        self.factory.factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: DiffCompatible, View: UIView>(byJoining factory: ViewCellItemsFactory<Object, View>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self).factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory(byJoining factory: ComplexCellItemsFactory) -> ComplexCellItemsFactory {
        self.factory.factory(byJoining: factory)
    }
}
