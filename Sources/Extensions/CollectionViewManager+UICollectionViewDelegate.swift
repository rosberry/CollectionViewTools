//
//  CollectionViewManager+UICollectionViewDelegate.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView,
                             shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath)?.shouldHighlight(for: collectionView, at: indexPath) ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didHighlightItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.didHighlight(for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didUnhighlightItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.didUnhighlight(for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath)?.shouldSelect(for: collectionView, at: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath)?.shouldDeselect(for: collectionView, at: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.didSelect(for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didDeselectItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.didDeselect(for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.willDisplay(cell: cell, for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplaySupplementaryView view: UICollectionReusableView,
                             forElementKind elementKind: String,
                             at indexPath: IndexPath) {
        cellItem(for: indexPath)?.willDisplay(view: view, for: elementKind, for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplaying cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
        cellItem(for: indexPath)?.didEndDisplaying(cell: cell, for: collectionView, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplayingSupplementaryView view: UICollectionReusableView,
                             forElementOfKind elementKind: String,
                             at indexPath: IndexPath) {
        cellItem(for: indexPath)?.didEndDisplaying(view: view, for: elementKind, for: collectionView, at: indexPath)
    }
}
