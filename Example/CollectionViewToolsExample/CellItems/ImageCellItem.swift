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
    
    func configure(_ cell: UICollectionViewCell) {
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
    
    deinit {
        print("\(self) deinit")
    }
    
    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        var shift = sectionItem.insets.left / 2 + sectionItem.insets.right / 2
        shift += shift / 2
        let ratio = image.size.width / image.size.height
        let width = (collectionView.bounds.width) / 2 - shift
        return .init(width: width, height: width / ratio)
    }
    
    func didSelect() {
        selectionHandler(image)
    }
}
