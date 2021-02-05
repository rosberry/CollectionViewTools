//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class ViewCellItemsFactory<Object: GenericDiffItem, View: UIView> {

    public typealias Cell = CollectionViewViewCell<View>
    public typealias CellItem = CollectionViewViewCellItem<Object, View>
    typealias AssociatedFactory = AssociatedCellItemFactory<Object, Cell>

    /// Set this handler to retrieve or create a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    public var initializationHandler: ((Object) -> [CollectionViewCellItem?])?

    /// Set this handler to configure the cell item
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object. Associated object can be retrieved with `cellItem.object`.
    public var cellItemConfigurationHandler: ((CellItem) -> Void)?

    /// Set this handler to provide size types for cellItem
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object. Associated object can be retrieved with `cellItem.object`.
    public var sizeTypesConfigurationHandler: ((CellItem) -> SizeTypes)?

    /// Set this handler to provide specific an instance of `View`
    ///
    /// - Parameters:
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object. Associated object can be retrieved with `cellItem.object`.
    public var viewInitializer: ((CellItem) -> View)? = { _ in
        .init()
    }

    // Set this handler to perform primary configuration of`View` after it will be instantiated
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object. Associated object can be retrieved with `cellItem.object`.
    public var viewInitialConfigurationHandler: ((View, CellItem) -> Void)?

    // Set this handler to perform view configuration on collection view cell reloading
    ///
    /// - Parameters:
    ///    - View: an instance  associated with `CellItem`
    ///    - CellItem: generated universal cell item or defined in `initializationHandler`  for this object. Associated object can be retrieved with `cellItem.object`.
    public var viewConfigurationHandler: ((View, CellItem) -> Void)?

    private lazy var sizeCell: CollectionViewViewCell<View> = {
        let cell = CollectionViewViewCell<View>()
        cell.bounds.size = .init(width: 1000, height: 1000)
        return cell
    }()

    private lazy var factory: AssociatedFactory = {
        let factory = AssociatedFactory()
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
        factory.initializationHandler = { [weak self] object in
            if let cellItem = self?.makeUniversalCellItem(object: object) {
                return [cellItem]
            }
            return []
        }
        return factory
    }()

    public lazy var hashKey: String? = .init(describing: Object.self)

    public init() {
        
    }

    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        (factory.makeCellItems(objects: objects) as? [CollectionViewDiffCellItem]) ?? []
    }

    public func makeUniversalCellItem(object: Object) -> CellItem {
        factory.makeUniversalCellItem(object: object)
    }
}

extension ViewCellItemsFactory: CellItemFactory {

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
}
