//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

open class ViewCellItemsFactory<Object: GenericDiffItem, View: UIView> {

    public typealias Cell = CollectionViewViewCell<View>
    public typealias CellItem = CollectionViewViewCellItem<Object, View>
    typealias AssociatedFactory = AssociatedCellItemFactory<Object, Cell>

    /// Set this handler to retrieve a specific set of cell items for the associated object
    ///
    /// - Parameters:
    ///    - Object: the object associated with a cell item
    public var initializationHandler: ((Object) -> [CollectionViewCellItem?])? {
        didSet {
            factory.initializationHandler = initializationHandler
        }
    }

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

    private lazy var factory: AssociatedFactory = {
        let factory = AssociatedFactory()
        factory.cellItemConfigurationHandler = { [weak self] cellItem in
            guard let cellItem = cellItem as? CellItem else {
                return
            }
            cellItem.sizeCell = self?.sizeCell
            self?.cellItemConfigurationHandler?(cellItem)
        }
        factory.cellConfigurationHandler = { cell, cellItem in
            guard let viewConfigurationHandler = self.viewConfigurationHandler else {
                fatalError("configurationHandler property for the CellItemFactory should be assigned before")
            }
            guard let cellItem = cellItem as? CellItem else {
                return
            }
            if let view = cell.view {
                viewConfigurationHandler(view, cellItem)
            }
            else {
                let view = self.viewInitializer?(cellItem) ?? View()
                self.viewInitialConfigurationHandler?(view, cellItem)
                cell.view = view
                viewConfigurationHandler(view, cellItem)
            }
        }
        return factory
    }()

    public lazy var hashKey: String? = .init(describing: Object.self)

    public func makeCellItems(objects: [Object]) -> [CollectionViewCellItem] {
        factory.makeCellItems(objects: objects)
    }

    public func makeDiffCellItems(objects: [Object]) -> [CollectionViewDiffCellItem] {
        (makeCellItems(objects: objects) as? [CollectionViewDiffCellItem]) ?? []
    }
}
