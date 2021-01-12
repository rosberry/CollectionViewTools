//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class ViewCellItemsFactory<Object: GenericDiffItem, View: UIView> {

    public typealias Cell = CollectionViewViewCell<View>
    public typealias CellItem = CollectionViewViewCellItem<Object, View>
    typealias Factory = CellItemsFactory<Object, Cell>

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    public var initializationHandler: ((Object) -> [CollectionViewCellItem?])?

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((Object, UICollectionView, CollectionViewSectionItem) -> CGSize)? {
        didSet {
            factory.sizeConfigurationHandler = sizeConfigurationHandler
        }
    }

    /// Set this handler to provide size types for cellItem
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    public var sizeTypesConfigurationHandler: ((Object) -> SizeTypes)?

    /// Set this handler to provide specific an instance of `View`
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object
    public var viewInitializer: ((CellItem) -> View)? = { _ in
        .init()
    }

    // Set this handler to perform primary configuration of`View` after it will be instantiated
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object
    public var viewInitialConfigurationHandler: ((View, CellItem) -> Void)?

    // Set this handler to perform view configuration on collection view cell reloading
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object
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
            cellItem.sizeTypes = self?.sizeTypesConfigurationHandler?(cellItem.object)
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
        factory.initializationHandler = { [weak self] object in
            if let initializationHandler = self?.initializationHandler {
                return initializationHandler(object)
            }
            if let cellItem = self?.makeUniversalCellItem(object: object) {
                return [cellItem]
            }
            return []
        }
        return factory
    }()

    public init() {
        
    }

    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        factory.makeCellItems(objects: objects)
    }

    public func makeDiffCellItems(objects: [Object]) -> [CollectionViewDiffCellItem] {
        (makeCellItems(objects: objects) as? [CollectionViewDiffCellItem]) ?? []
    }

    public func makeUniversalCellItem(object: Object) -> CellItem {
        factory.makeUniversalCellItem(object: object)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: GenericDiffItem, Cell: UICollectionViewCell>(byJoining factory: CellItemsFactory<Object, Cell>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: factory).factory(byJoining: factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory<Object: GenericDiffItem, View: UIView>(byJoining factory: ViewCellItemsFactory<Object, View>) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: self.factory).factory(byJoining: factory.factory)
    }

    /// Joins different cell item factories
    ///
    /// - Parameters:
    ///    - factory: a second cell item factory the associated type of which should be united
    public func factory(byJoining factory: ComplexCellItemsFactory) -> ComplexCellItemsFactory {
        ComplexCellItemsFactory().factory(byJoining: factory).factory(byJoining: factory)
    }
}
