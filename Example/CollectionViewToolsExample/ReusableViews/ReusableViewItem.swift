//
//  ReusableViewItem.swift
//  CollectionViewToolsExample
//
//  Created by Стас Клюхин on 17/06/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class ReusableViewItem: CollectionViewReusableViewItem {
    var type: ReusableViewType = .header

    var classType: UIView.Type {
        return ReusableView.self
    }

    func view(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(with: self, at: indexPath)
    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        let height: CGFloat = 150
        return .init(width: collectionView.frame.width, height: height)
    }
}
