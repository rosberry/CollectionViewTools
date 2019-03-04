//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public typealias CollectionViewDiffableCellItem = CollectionViewCellItem & CollectionViewDiffableItem

extension CollectionViewSectionItem {

    var diffableCellItems: [CollectionViewDiffableCellItem] {
        return cellItems.compactMap { $0 as? CollectionViewDiffableCellItem }
    }
}
