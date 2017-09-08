//
//  CollectionViewCellItemDataSourcePrefetching.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public protocol CollectionViewCellItemDataSourcePrefetching {
    
    func prefetchData(for collectionView: UICollectionView, at indexPath: IndexPath)
    func cancelPrefetchingData(for collectionView: UICollectionView, at indexPath: IndexPath)
}

public extension CollectionViewCellItemDataSourcePrefetching {
    
    func prefetchData(for collectionView: UICollectionView, at indexPath: IndexPath) {}
    func cancelPrefetchingData(for collectionView: UICollectionView, at indexPath: IndexPath) {}
}
