//
//  CollectionViewManager+UICollectionViewDelegateFlowLayout.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellItem = cellItem(for: indexPath),
              let sectionItem = cellItem.sectionItem else {
            return .zero
        }
        let size: CGSize
        if let cachedSize = cellItem.cachedSize {
            size = cachedSize
        }
        else {
            size = cellItem.size(in: collectionView, sectionItem: sectionItem)
            cellItem.cachedSize = size
        }
        return size
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        return _sectionItems[section].insets
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return _sectionItems[section].minimumLineSpacing
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return _sectionItems[section].minimumInteritemSpacing
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        let optionalItem = _sectionItems[section].reusableViewItems.first { reusableViewItem in
            reusableViewItem.type == .header
        }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> CGSize {
        let optionalItem = _sectionItems[section].reusableViewItems.first { reusableViewItem in
            reusableViewItem.type == .footer
        }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
}
