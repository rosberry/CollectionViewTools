//
//  ImageCellItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import CollectionViewTools
import Foundation

final class ImageCellItem: CollectionViewCellItem {
    
    typealias Cell = ImageCollectionViewCell
    private(set) var reuseType: ReuseType = .class(Cell.self)
    private let image: UIImage
    private let selectionHandler: (UIImage) -> Void
    var removeActionHandler: (() -> Void)?
    
    func configure(cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.imageView.image = image
        cell.removeActionHandler = removeActionHandler
    }
    
    init(image: UIImage, selectionHandler: @escaping (UIImage) -> Void) {
        self.image = image
        self.selectionHandler = selectionHandler
    }
    
    func size(for collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        let ratio = image.size.width / image.size.height
        let width = collectionView.bounds.width / 2 - 16
        return .init(width: width, height: width / ratio)
    }
    
    func didSelect(for collectionView: UICollectionView, at indexPath: IndexPath) {
        selectionHandler(image)
    }
}
