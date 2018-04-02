//
//  ImageCellItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import CollectionViewTools

class ImageCellItem: CollectionViewCellItemProtocol {

    typealias Cell = ImageCollectionViewCell
    let image: UIImage

    var reuseType: ReuseType {
        return ReuseType(cellClass: Cell.self)
    }

    init(image: UIImage) {
        self.image = image
    }
    
    func size(for collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func configure(cell: ImageCollectionViewCell, at indexPath: IndexPath) {

    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return size(for: collectionView, at: indexPath)
    }
}
