//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDelegate {

    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath, onlyFetch: true)?.shouldHighlight(at: indexPath) ?? false
    }

    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didHighlight(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didUnhighlight(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath, onlyFetch: true)?.shouldSelect(at: indexPath) ?? true
    }

    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath, onlyFetch: true)?.shouldDeselect(at: indexPath) ?? true
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didSelect(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didDeselect(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.willDisplay(cell: cell, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplaying cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didEndDisplaying(cell: cell, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             willDisplaySupplementaryView view: UICollectionReusableView,
                             forElementKind elementKind: String,
                             at indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.willDisplay(view: view, for: elementKind, for: collectionView, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplayingSupplementaryView view: UICollectionReusableView,
                             forElementOfKind elementKind: String,
                             at indexPath: IndexPath) {
        cellItem(for: indexPath, onlyFetch: true)?.didEndDisplaying(view: view, for: elementKind, for: collectionView, at: indexPath)
    }
}
