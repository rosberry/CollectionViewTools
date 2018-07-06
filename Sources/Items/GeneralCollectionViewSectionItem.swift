//
//  GeneralCollectionViewSectionItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class GeneralCollectionViewSectionItem: CollectionViewSectionItem {
    
    open var cellItems: [CollectionViewCellItem]
    open var reusableViewItems: [CollectionViewReusableViewItem]
    
    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero
    
    public init(cellItems: [CollectionViewCellItem] = [],
                reusableViewItems: [CollectionViewReusableViewItem] = []) {
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
