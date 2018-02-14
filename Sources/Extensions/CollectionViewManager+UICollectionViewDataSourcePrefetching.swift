//
//  CollectionViewManager+UICollectionViewDataSourcePrefetching.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDataSourcePrefetching {
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let cellItem = cellItem(for: indexPath) {
                cellItem.prefetchData(for: collectionView, at: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let cellItem = cellItem(for: indexPath) {
                cellItem.cancelPrefetchingData(for: collectionView, at: indexPath)
            }
        }
    }
}
