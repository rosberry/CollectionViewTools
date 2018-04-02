//
//  ImageAndTitleCellItem.swift
//  CollectionViewToolsExample
//
//  Created by Dmitry Frishbuter on 23/03/2018.
//  Copyright © 2018 Rosberry. All rights reserved.
//

import CollectionViewTools

class ImageAndTitleCellItem: ImageCellItem {

    override var reuseType: ReuseType {
        return ReuseType(cellClass: ImageAndTitleCollectionViewCell.self)
    }

    let title: String

    init(image: UIImage, title: String) {
        self.title = title
        super.init(image: image)
    }

    override func size(for collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    override func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return size(for: collectionView, at: indexPath)
    }
}
