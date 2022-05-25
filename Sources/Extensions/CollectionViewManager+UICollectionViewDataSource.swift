//
//  CollectionViewManager+UICollectionViewDataSource.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDataSource {

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.itemDataSource(at: section)?.itemCount ?? 0
        }

        return _sectionItems[section].cellItems.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellItem = self.cellItem(for: indexPath)!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellItem.reuseType.identifier, for: indexPath)
        cellItem.configure(cell)
        cellItem.configure(cell, animated: false)
        return cell
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let dataSource = dataSource {
            return dataSource.sectionCount
        }

        return _sectionItems.count
    }

    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        guard let reusableViewItem = self.reusableViewItem(for: indexPath, kind: kind) else {
            return UICollectionReusableView()
        }
        let kind = reusableViewItem.type.kind
        let identifier = reusableViewItem.reuseType.identifier
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: identifier,
                                                                   for: indexPath)
        reusableViewItem.configure(view)
        return view
    }

    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return cellItem(for: indexPath)?.canMove() ?? false
    }

    open func collectionView(_ collectionView: UICollectionView,
                             moveItemAt sourceIndexPath: IndexPath,
                             to destinationIndexPath: IndexPath) {
        guard let sourceSectionItem = self.sectionItem(for: sourceIndexPath),
              let destinationIndexPathSectionItem = self.sectionItem(for: destinationIndexPath) else {
            return
        }
        let cellItem = sourceSectionItem.cellItems.remove(at: sourceIndexPath.row)
        destinationIndexPathSectionItem.cellItems.insert(cellItem, at: destinationIndexPath.row)
        moveItemsHandler?(collectionView, sourceIndexPath, destinationIndexPath)
    }
}
