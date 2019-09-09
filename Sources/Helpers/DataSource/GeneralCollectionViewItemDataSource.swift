//
//  GeneralCollectionViewItemDataSource.swift
//  CollectionViewTools
//
//  Created by Anton K on 4/29/19.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

open class GeneralCollectionViewItemDataSource: CollectionViewItemDataSource {
    public let itemCount: Int

    public var cellItemProvider: (Int) -> CollectionViewCellItem?
    public var sizeProvider: (Int, UICollectionView) -> CGSize

    private var cache: [Int: CollectionViewCellItem] = [:]

    public init(count: Int,
                cellItemProvider: @escaping (Int) -> CollectionViewCellItem?,
                sizeProvider: @escaping (Int, UICollectionView) -> CGSize) {
        self.itemCount = count
        self.cellItemProvider = cellItemProvider
        self.sizeProvider = sizeProvider
    }

    open func cellItem(at index: Int) -> CollectionViewCellItem? {
        if let cachedCellItem = cache[index] {
            return cachedCellItem
        }

        guard index < itemCount else {
            return nil
        }

        guard let cellItem = cellItemProvider(index) else {
            return nil
        }

        cache[index] = cellItem
        return cellItem
    }

    open func sizeForCell(at index: Int, in collectionView: UICollectionView) -> CGSize {
        return sizeProvider(index, collectionView)
    }
}
