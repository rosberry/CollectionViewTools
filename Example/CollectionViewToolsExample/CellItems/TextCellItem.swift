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
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        let numberOfActionsInRow: CGFloat = 3
        let width = collectionView.bounds.width / numberOfActionsInRow
        return .init(width: width - (numberOfActionsInRow + 1) * 8, height: collectionView.bounds.height / 1.4)
    }
}
