//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

// This factory type eraser that allows to organize different factory access in `ComplexCellItemsFactory`
protocol AnyCellItemsFactory {
    var hashKey: String? { get }
    func makeCellItem(object: Any) -> CollectionViewCellItem?
}

// Type eraser for `CellItemsFactory<Object, Cell>`
final class AnyAssociatedCellItemsFactory<Object: DiffCompatible, Cell: UICollectionViewCell>: AnyCellItemsFactory {
    private let factory: CellItemsFactory<Object, Cell>
    init(_ factory: CellItemsFactory<Object, Cell>) {
        self.factory = factory
    }

    let hashKey: String? = String(describing: Object.self)

    func makeCellItem(object: Any) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return factory.makeCellItem(object: object)
    }
}

// Type eraser for `ViewCellItemsFactory<Object, View>`
final class AnyViewCellItemsFactory<Object: DiffCompatible, View: UIView>: AnyCellItemsFactory {
    private let factory: ViewCellItemsFactory<Object, View>
    init(_ factory: ViewCellItemsFactory<Object, View>) {
        self.factory = factory
    }

    let hashKey: String? = String(describing: Object.self)

    func makeCellItem(object: Any) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return factory.makeCellItem(object: object)
    }
}

// Type eraser for `ComplexCellItemsFactory`
final class AnyComplexCellItemsFactory: AnyCellItemsFactory {

    private let factory: ComplexCellItemsFactory
    init(_ factory: ComplexCellItemsFactory) {
        self.factory = factory
    }

    let hashKey: String? = nil

    func makeCellItem(object: Any) -> CollectionViewCellItem? {
        factory.makeCellItem(object: object)
    }
}
