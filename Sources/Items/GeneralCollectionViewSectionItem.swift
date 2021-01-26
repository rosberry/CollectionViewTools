//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

/// Base section item that conforms `CollectionViewSectionItem` protocol.
open class GeneralCollectionViewSectionItem: CollectionViewSectionItem {

    open var cellItems: [CollectionViewCellItem]
    open var reusableViewItems: [CollectionViewReusableViewItem]

    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero

    public init(cellItems: [CollectionViewCellItem] = [], reusableViewItems: [CollectionViewReusableViewItem] = []) {
        self.cellItems = cellItems
        self.reusableViewItems = reusableViewItems
    }
}
