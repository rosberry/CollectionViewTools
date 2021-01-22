//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public enum ReusableViewType {
    case header
    case footer

    public var kind: String {
        switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
        }
    }
}

public protocol CollectionViewReusableViewItem: CollectionViewSiblingItem {

    var type: ReusableViewType { get set }

    var reuseType: ReuseType { get }

    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout) -> CGSize
    func configure(_ view: UICollectionReusableView)
}
