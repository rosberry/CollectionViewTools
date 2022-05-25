//
//  Copyright © 2020 Rosberry. All rights reserved.
//

@testable import CollectionViewTools

final class TestReusableViewItem: CollectionViewReusableViewItem {

    let title: String

    var type: ReusableViewType = .header
    let reuseType: ReuseType = .class(TestReusableView.self)

    init(title: String) {
        self.title = title
    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }

    func configure(_ view: UICollectionReusableView) {
        guard let view = view as? TestReusableView else {
            return
        }
        view.title = title
    }
}
