//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class UniversalCollectionViewCellItem<Object: DiffCompatible, Cell: UICollectionViewCell>: CollectionViewDiffCellItem {

    public lazy var reuseType = ReuseType.class(Cell.self)

    public var diffIdentifier: String {
        "\(object.diffIdentifier):\(reuseIdentifier)"
    }

    private var reuseIdentifier: String {
        String(describing: type(of: self))
    }

    public let object: Object
    private let comparator: Object.DiffComparator

    required init(object: Object) {
        self.comparator = object.makeDiffComparator()
        self.object = object
    }

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: collection view cell that should be configured
    public var configurationHandler: ((Cell) -> Void)?

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((UICollectionView, CollectionViewSectionItem) -> CGSize)?

    public func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        configurationHandler?(cell)
    }

    public func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return sizeConfigurationHandler?(collectionView, sectionItem) ?? .zero
    }

    public func isEqual(to item: DiffItem) -> Bool {
        guard let cellItem = item as? UniversalCollectionViewCellItem<Object, Cell> else {
            return false
        }
        let objectDescriptor = object.makeDiffComparator()
        let cellItemObjectDescriptor = cellItem.object.makeDiffComparator()
        return comparator == cellItem.comparator &&
               comparator == objectDescriptor &&
               objectDescriptor == cellItemObjectDescriptor
    }
}
