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
    
    private func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.titleLabel.text = text
    }
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width - 2 * 16, height: collectionView.bounds.height)
    }
}
