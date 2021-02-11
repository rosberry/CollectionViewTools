//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import CollectionViewTools

final class TextCellItem: CollectionViewDiffCellItem {

    private typealias Cell = TextContentCollectionViewCell

    private static let sizeCell: Cell = .init()

    private(set) var reuseType: ReuseType = .class(Cell.self)

    let text: String
    let backgroundColor: UIColor
    let font: UIFont
    let roundCorners: Bool
    let contentRelatedWidth: Bool

    init(text: String,
         backgroundColor: UIColor = .white,
         font: UIFont = .systemFont(ofSize: 12),
         roundCorners: Bool = false,
         contentRelatedWidth: Bool = true) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.font = font
        self.roundCorners = roundCorners
        self.contentRelatedWidth = contentRelatedWidth
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }
        cell.contentView.backgroundColor = backgroundColor
        cell.contentView.layer.cornerRadius = roundCorners ? 4 : 0
        cell.textContentView.titleLabel.font = font
        cell.textContentView.titleLabel.text = text
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        let cell: Cell = type(of: self).sizeCell
        configure(cell)
        let cellSize = cell.sizeThatFits(.init(width: collectionView.bounds.size.width, height: .greatestFiniteMagnitude))
        let contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let height = cellSize.height + contentInsets.top + contentInsets.bottom
        if contentRelatedWidth {
            return .init(width: cellSize.width + contentInsets.left + contentInsets.right, height: height)
        }
        else {
            let sectionInsets = sectionItem.insets
            return .init(width: collectionView.bounds.width - sectionInsets.left - sectionInsets.right,
                         height: height)
        }
    }

    // MARK: - DiffItem

    var diffIdentifier: String = ""

    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? TextCellItem else {
            return false
        }
        return text == item.text
            && backgroundColor == item.backgroundColor
            && font == item.font
            && roundCorners == item.roundCorners
            && contentRelatedWidth == item.contentRelatedWidth
    }
}
