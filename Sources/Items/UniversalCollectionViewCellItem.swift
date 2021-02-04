//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public final class UniversalCollectionViewCellItem<U: GenericDiffItem, T: UICollectionViewCell>: CollectionViewDiffCellItem {

    public lazy var reuseType = ReuseType.classWithIdentifier(T.self, identifier: diffIdentifier)
    public lazy var diffIdentifier: String = "\(String(describing: type(of: self))){\(object.diffIdentifier)}"
    public let object: U

    init(object: U) {
        self.object = object
    }

    /// Set this handler to configure the cell
    ///
    /// - Parameters:
    ///    - UICollectionViewCell: collection view cell that should be configured
    public var configurationHandler: ((T) -> Void)?

    /// Set this handler to configure the size of cell
    ///
    /// - Parameters:
    ///    - UICollectionView: collection view where cell should be placed
    ///    - CollectionViewSectionItem: a section item in the section of which the cell should be placed
    public var sizeConfigurationHandler: ((UICollectionView, CollectionViewSectionItem) -> CGSize)?

    public func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? T else {
            return
        }
        configurationHandler?(cell)
    }

    public func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return sizeConfigurationHandler?(collectionView, sectionItem) ?? .zero
    }

    public func isEqual(to item: DiffItem) -> Bool {
        guard let cellItem = item as? UniversalCollectionViewCellItem<U, T> else {
            return false
        }
        return object.isEqual(to: cellItem)
    }
}
