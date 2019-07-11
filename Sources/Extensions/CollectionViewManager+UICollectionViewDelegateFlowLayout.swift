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
        if let dataSource = dataSource {
            return dataSource.itemDataSource(at: indexPath.section)?.sizeForCell(at: indexPath.row, in: collectionView) ?? .zero
        }

        guard let cellItem = cellItem(for: indexPath) else {
            return .zero
        }
        return cellItem.size()
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionItem = dataSource?.sectionItem(at: section) ?? _sectionItems[section]
        return sectionItem.insets
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionItem = dataSource?.sectionItem(at: section) ?? _sectionItems[section]
        return sectionItem.minimumLineSpacing
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionItem = dataSource?.sectionItem(at: section) ?? _sectionItems[section]
        return sectionItem.minimumInteritemSpacing
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionItem = dataSource?.sectionItem(at: section) ?? _sectionItems[section]
        let optionalItem = sectionItem.reusableViewItems.first { $0.type == .header }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionItem = dataSource?.sectionItem(at: section) ?? _sectionItems[section]
        let optionalItem = sectionItem.reusableViewItems.first { $0.type == .footer }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
}
