//
//  CollectionViewSectionItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class CollectionViewSectionItem: CollectionViewSectionItemProtocol {
    
    open var cellItems: [CollectionViewCellItemProtocol]
    open var reusableViewItems: [CollectionViewReusableViewItemProtocol]
    
    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero
    
    public init(cellItems: [CollectionViewCellItemProtocol] = [],
                reusableViewItems: [CollectionViewReusableViewItemProtocol] = []) {
        self.cellItems = cellItems
        self.reusableViewItems = reusableViewItems
    }
    
    public func inset(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> UIEdgeInsets {
        return insets
    }
    
    public func minimumLineSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat {
        return minimumLineSpacing
    }
    
    public func minimumInteritemSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat {
        return minimumInteritemSpacing
    }
}
