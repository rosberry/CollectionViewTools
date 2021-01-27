//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

final class ReusableViewItem: CollectionViewReusableViewItem {

    var type: ReusableViewType = .header

    var reuseType: ReuseType = .class(ReusableView.self)

    func configure(_ view: UICollectionReusableView) {
        guard let view = view as? ReusableView else {
            return
        }

        view.backgroundColor = .green
    }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize {
        let height: CGFloat = 150
        return .init(width: collectionView.frame.width, height: height)
    }
}
