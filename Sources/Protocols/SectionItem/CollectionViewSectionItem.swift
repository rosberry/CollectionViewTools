//
//  CollectionViewSectionItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public protocol CollectionViewSectionItem: AnyObject {
    
    var cellItems: [CollectionViewCellItem] { get set }
    var reusableViewItems: [CollectionViewReusableViewItem] { get set }
    
    func inset(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> UIEdgeInsets
    func minimumLineSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat
    func minimumInteritemSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat
}

public extension CollectionViewSectionItem {
    
    func inset(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> UIEdgeInsets {
        return .zero
    }
    
    func minimumLineSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat {
        return 0
    }
    
    func minimumInteritemSpacing(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGFloat {
        return 0
    }
}
