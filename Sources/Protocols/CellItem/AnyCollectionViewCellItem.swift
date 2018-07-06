//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class AnyCollectionViewCellItem<T>: CollectionViewCellItem where T: UICollectionViewCell {
    
    public typealias Cell = T
    
    private let _configure: (T, IndexPath) -> Void
    private let _reuseType: () -> ReuseType
    
    public var reuseType: ReuseType {
        return _reuseType()
    }
    
    public init<U: CollectionViewCellItem>(_ cellItem: U) where U.Cell == T {
        _configure = { [weak cellItem] (cell, indexPath) in
            guard let cellItem = cellItem else {
                return
            }
            cellItem.configure(cell: cell, at: indexPath)
        }
        _reuseType = { [weak cellItem] in
            guard let cellItem = cellItem else {
                fatalError("It is impossible to create cell item without reuse type")
            }
            return cellItem.reuseType
        }
    }
    
    public func configure(cell: Cell, at indexPath: IndexPath) {
        _configure(cell, indexPath)
    }
}
