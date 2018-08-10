//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import CollectionViewTools

final class TextCellItem: CollectionViewCellItem {
    
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    private typealias Cell = TextCollectionViewCell
    private(set) var reuseType: ReuseType = .class(Cell.self)
    
    func configure(cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.titleLabel.text = text
    }
    
    private static let sizeCell: Cell = .init()
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        let cell: Cell = type(of: self).sizeCell
        configure(cell: cell, at: indexPath)
        let cellSize = cell.sizeThatFits(.init(width: collectionView.bounds.size.width, height: .greatestFiniteMagnitude))
        return .init(width: cellSize.width + 2 * 12, height: collectionView.bounds.height / 1.4)
    }
}
