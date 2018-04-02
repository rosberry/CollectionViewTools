//
//  CollectionViewCellItem.swift
//  CollectionViewTools
//
//  Created by Dmitry Frishbuter on 23/03/2018.
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

public protocol UICollectionViewCellProtocol: AnyObject {
}

extension UICollectionViewCell: UICollectionViewCellProtocol {}

public class AnyCollectionViewCellItem<T>: CollectionViewCellItemProtocol where T: UICollectionViewCellProtocol {

    public typealias Cell = T

    public var reuseType: ReuseType {
        return _reuseType()
    }

    private let _configure: (T, IndexPath) -> Void
    private let _reuseType: () -> ReuseType

    public init<U: CollectionViewCellItemProtocol>(_ cellItem: U) where U.Cell == T {
        _configure = { [weak cellItem] (cell, indexPath) in
            guard let cellItem = cellItem else {
                return
            }
            cellItem.configure(cell: cell, at: indexPath)
        }
        _reuseType = { [weak cellItem] in
            return cellItem?.reuseType ?? ReuseType(cellClass: T.self)
        }
    }

    public func configure(cell: Cell, at indexPath: IndexPath) {
        _configure(cell, indexPath)
    }
}

//open class CollectionViewCellItem: CollectionViewCellItemProtocol {
//
//    public typealias Cell = UICollectionViewCell
//
//    open var reuseType: ReuseType {
//        return ReuseType(cellClass: Cell.self)
//    }
//
//    open func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
//        return cell
//    }
//}

