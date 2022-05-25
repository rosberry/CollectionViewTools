//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class HeaderViewItem: CollectionViewDiffReusableViewItem {

    typealias View = HeaderView

    var type: ReusableViewType = .header
    var reuseType: ReuseType = .class(View.self)

    var foldHandler: (() -> Void)?
    var removeHandler: (() -> Void)?

    var title: String
    var backgroundColor: UIColor
    var isFolded: Bool

    var diffIdentifier: String = ""

    init(title: String, backgroundColor: UIColor, isFolded: Bool) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.isFolded = isFolded
    }

    func configure(_ view: UICollectionReusableView) {
        guard let view = view as? View else {
            return
        }
        view.contentView.backgroundColor = backgroundColor
        view.label.text = title
        let foldButtonTitle = isFolded ? "Unfold" : "Fold"
        view.foldButton.setTitle(foldButtonTitle, for: .normal)
        view.removeHandler = { [weak self] in
            self?.removeHandler?()
        }
        view.foldHandler = { [weak self] in
            self?.foldHandler?()
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }

    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? HeaderViewItem else {
            return false
        }
        return title == item.title &&
            isFolded == item.isFolded
    }
}
