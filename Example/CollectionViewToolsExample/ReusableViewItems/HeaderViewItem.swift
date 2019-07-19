//
//  HeaderViewItem.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class HeaderViewItem: CollectionViewDiffReusableViewItem {
    var type: ReusableViewType = .header
    
    typealias View = HeaderView
    
    var selectionHandler: (() -> Void)?

    var title: String
    
    var diffIdentifier: String = ""
    
    init(title: String) {
        self.title = title
    }
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func view(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: type.kind,
                                                                         withReuseIdentifier: NSStringFromClass(View.self),
                                                                         for: indexPath) as? View else {
                                                                            return HeaderView()
        }
        headerView.label.text = title
        headerView.selectionHandler = { [weak self] in
            self?.selectionHandler?()
        }
        return headerView
    }
    
    func register(for collectionView: UICollectionView) {
        collectionView.register(View.self,
                                forSupplementaryViewOfKind: type.kind,
                                withReuseIdentifier: NSStringFromClass(View.self))
    }
    
    func equal(to item: DiffItem) -> Bool {
        guard let item = item as? HeaderViewItem else {
            return false
        }
        return title == item.title
    }
}
