//
//  HeaderViewItem.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class HeaderViewItem: CollectionViewDiffReusableViewItem {
    var type: ReusableViewType = .header
    
    typealias View = HeaderView
    
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
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
    func view(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: type.kind,
                                                                         withReuseIdentifier: NSStringFromClass(View.self),
                                                                         for: indexPath) as? View else {
                                                                            return HeaderView()
        }
        headerView.contentView.backgroundColor = backgroundColor
        headerView.label.text = title
        let foldButtonTitle = isFolded ? "Unfold" : "Fold"
        headerView.foldButton.setTitle(foldButtonTitle, for: .normal)
        headerView.removeHandler = { [weak self] in
            self?.removeHandler?()
        }
        headerView.foldHandler = { [weak self] in
            self?.foldHandler?()
        }
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        return headerView
    }
    
    func register(for collectionView: UICollectionView) {
        collectionView.register(View.self,
                                forSupplementaryViewOfKind: type.kind,
                                withReuseIdentifier: NSStringFromClass(View.self))
    }
    
    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? HeaderViewItem else {
            return false
        }
        return title == item.title &&
            isFolded == item.isFolded
    }
}
