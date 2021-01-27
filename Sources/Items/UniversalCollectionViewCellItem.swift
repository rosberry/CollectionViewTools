//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public class UniversalCollectionViewCellItem<Object: CanBeDiff, Cell: UICollectionViewCell>: CollectionViewDiffCellItem {

    public lazy var reuseType = ReuseType.class(Cell.self)

    public var diffIdentifier: String {
        "\(object.debugDescription):\(reuseIdentifier)"
    }

    private var reuseIdentifier: String {
        String(describing: type(of: self))
    }

    public let object: Object
    private let originalObject: Object

    required init(object: Object) {
        if let object = object as? NSCopying {
            self.originalObject = object.copy(with: nil) as! Object
        }
        else {
            self.originalObject = object
        }
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
        return object == cellItem.object && object == originalObject && cellItem.object == originalObject
    }
}
