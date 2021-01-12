//
//  Copyright © 2020 Rosberry. All rights reserved.
//

protocol AnyCellItemsFactory {
    var hashKey: String? { get }
    func makeCellItems(object: Any) -> [CollectionViewCellItem]
    func makeCellItem(object: Any) -> CollectionViewCellItem?
}

final class AnyAssociatedCellItemsFactory<Object: GenericDiffItem, Cell: UICollectionViewCell>: AnyCellItemsFactory {
    private let factory: CellItemsFactory<Object, Cell>
    init(_ factory: CellItemsFactory<Object, Cell>) {
        self.factory = factory
    }

    let hashKey : String? = String(describing: Object.self)

    func makeCellItems(object: Any) -> [CollectionViewCellItem] {
        guard let object = object as? Object else {
            return []
        }
        return factory.makeCellItems(object: object)
    }

    func makeCellItem(object: Any) -> CollectionViewCellItem? {
        guard let object = object as? Object else {
            return nil
        }
        return factory.makeUniversalCellItem(object: object)
    }
}

final class AnyComplexCellItemsFactory: AnyCellItemsFactory {

    private let factory: ComplexCellItemsFactory
    init(_ factory: ComplexCellItemsFactory) {
        self.factory = factory
    }

    let hashKey : String? = nil

    func makeCellItems(object: Any) -> [CollectionViewCellItem] {
        factory.makeCellItems(object: object)
    }

    func makeCellItem(object: Any) -> CollectionViewCellItem? {
        factory.makeCellItem(object: object)
    }
}
