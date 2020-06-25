//
//  UniversalCollectionViewCellItem.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public final class UniversalCollectionViewCellItem<T: UICollectionViewCell>: CollectionViewDiffCellItem {

    public let reuseType = ReuseType.class(T.self)
    public var context = [String: Any]()
    public lazy var diffIdentifier: String = .init(describing: self)
    
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

    /// Set this handler to compare objects
    ///
    /// - Parameters:
    ///    - Any?: first cellItem that should be compared
    ///    - Any?: second cellItem that should be compared
    public var isEqualHandler: ((UniversalCollectionViewCellItem<T>) -> Bool)?
    
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
        guard let cellItem = item as? UniversalCollectionViewCellItem<T> else {
            return false
        }
        return isEqualHandler?(cellItem) ?? true
    }
}
