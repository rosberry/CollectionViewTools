//
//  ImageCellItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import CollectionViewTools

import Foundation

final class ImageCellItem: CollectionViewCellItem {
    
    private let image: UIImage
    private let selectionHandler: (UIImage) -> Void
    
    var reuseType = ReuseType(cellClass: ImageCollectionViewCell.self)
    
    init(image: UIImage, selectionHandler: @escaping (UIImage) -> Void) {
        self.image = image
        self.selectionHandler = selectionHandler
    }
    
    func size(for collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.imageView.image = image
        return cell
    }
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return size(for: collectionView, at: indexPath)
    }
    
    func didSelect(for collectionView: UICollectionView, at indexPath: IndexPath) {
        selectionHandler(image)
    }
}
