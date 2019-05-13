//
//  ColorCellItem.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools
import Foundation

final class ColorCellItem: CollectionViewCellItem, CollectionViewDiffableItem {

    typealias Cell = ColorCollectionViewCell
    private(set) var reuseType: ReuseType = .class(Cell.self)

    private var color: UIColor

    init(color: UIColor) {
        self.color = color
    }

    deinit {
        print("\(self) deinit")
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.contentView.backgroundColor = color
        cell.label.text = "\(indexPath?.item ?? 0)"
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        let numberOfItemsInRow: CGFloat = 4
        let width = (collectionView.bounds.width - sectionItem.insets.left - sectionItem.insets.right -
        sectionItem.minimumInteritemSpacing * (numberOfItemsInRow - 1)) / numberOfItemsInRow
        return .init(width: width, height: width)
    }

    // MARK: - CollectionViewDiffableItem

    var identifier: String = ""

    func equal(to item: CollectionViewDiffableItem) -> Bool {
        guard let item = item as? ColorCellItem else {
            return false
        }
        return color == item.color
    }
}
