//
//  GeneralCollectionViewSectionItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class GeneralCollectionViewSectionItem: CollectionViewSectionItem {
    
    open var cellItems: [CollectionViewManager.CellItem]
    open var reusableViewItems: [CollectionViewReusableViewItem]
    
    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero
    
    public init(cellItems: [CollectionViewManager.CellItem] = [], reusableViewItems: [CollectionViewReusableViewItem] = []) {
        self.cellItems = cellItems
        self.reusableViewItems = reusableViewItems
    }
}
