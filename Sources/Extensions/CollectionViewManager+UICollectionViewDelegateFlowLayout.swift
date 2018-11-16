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
        return cellItem.size(in: collectionView, sectionItem: sectionItem)
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
        let optionalItem = _sectionItems[section].reusableViewItems.filter { $0.type == .header }.first
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> CGSize {
        let optionalItem = _sectionItems[section].reusableViewItems.filter { $0.type == .footer }.first
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
}
