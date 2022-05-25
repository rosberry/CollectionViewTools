//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class SpacerCellItem: CollectionViewDiffCellItem {

    typealias Cell = SpacerCell

    let reuseType: ReuseType = .class(Cell.self)
    let diffIdentifier: String = String(describing: Cell.self)

    func isEqual(to item: DiffItem) -> Bool {
        false
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.spacerView.dividerView.backgroundColor = .lightGray
        cell.spacerView.dividerInsets = .init(top: 9, left: 0, bottom: 0, right: 0)
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 20)
    }
}
