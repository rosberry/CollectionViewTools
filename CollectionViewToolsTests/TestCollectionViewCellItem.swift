//
//  Copyright © 2020 Rosberry. All rights reserved.
//

@testable import CollectionViewTools

final class TestCollectionViewCellItem: CollectionViewCellItem {

    let reuseType: ReuseType = .class(TestCollectionViewCell.self)

    var text: String
    let selectedText: String
    let highlightedText: String

    init(text: String, selectedText: String? = nil, highlightedText: String? = nil) {
        self.text = text
        self.selectedText = selectedText ?? text
        self.highlightedText = highlightedText ?? text
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? TestCollectionViewCell else {
            return
        }
        cell.text = text

        itemDidSelectHandler = { _ in
            cell.text = self.selectedText
        }

        itemDidDeselectHandler = { _ in
            cell.text = self.text
        }

        itemDidHighlightHandler = { _ in
            cell.text = self.highlightedText
        }

        itemDidUnhighlightHandler = itemDidDeselectHandler
        itemCanMoveResolver = nil
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
