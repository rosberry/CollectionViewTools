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
        let size = cellItem.size(in: collectionView, sectionItem: sectionItem)
        if cellItem.cachedSize == nil {
            cellItem.cachedSize = size
        }
        return size
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionItems[section].insets
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionItems[section].minimumLineSpacing
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionItems[section].minimumInteritemSpacing
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        let optionalItem = sectionItems[section].reusableViewItems.first { reusableViewItem in
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
        let optionalItem = sectionItems[section].reusableViewItems.first { reusableViewItem in
            reusableViewItem.type == .footer
        }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
}
