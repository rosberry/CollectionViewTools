//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

/// `UniversalCollectionViewCellItem` is implementation of `CollectionViewDiffCellItem` that use generic types association and
/// additional handlers to avoid derivation.
public class UniversalCollectionViewCellItem<U: GenericDiffItem, T: UICollectionViewCell>: CollectionViewDiffCellItem {

    /// Defines the type of cell that should be instantiated.
    public lazy var reuseType = ReuseType.classWithIdentifier(T.self, identifier: diffIdentifier)

    /// Defines an identifier to find the difference between logically different cell items.
    public lazy var diffIdentifier: String = "\(String(describing: type(of: self))){\(object.diffIdentifier)}"

    /// Provides an association of object that presents data model or view state of cell item
    public let object: U

    required init(object: U) {
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
