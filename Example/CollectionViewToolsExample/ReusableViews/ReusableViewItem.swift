//
//  ReusableViewItem.swift
//  CollectionViewToolsExample
//
//  Created by Стас Клюхин on 17/06/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class ReusableViewItem: CollectionViewReusableViewItem {

    var classType: UICollectionReusableView.Type = ReusableView.self

    var type: ReusableViewType = .header

    func configure(_ view: UICollectionReusableView) {
        guard let view = view as? ReusableView else {
            return
        }

        view.backgroundColor = .green
    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        let height: CGFloat = 150
        return .init(width: collectionView.frame.width, height: height)
    }
}
