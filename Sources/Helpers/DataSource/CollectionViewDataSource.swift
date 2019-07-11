//
//  CollectionViewDataSource.swift
//  CollectionViewTools
//
//  Created by Anton K on 4/25/19.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public protocol CollectionViewSectionDataSource {
    var sectionCount: Int { get }

    func sectionItem(at index: Int) -> CollectionViewSectionItem?
    func itemDataSource(at index: Int) -> CollectionViewItemDataSource?
}

public protocol CollectionViewItemDataSource {
    var itemCount: Int { get }

    func cellItem(at index: Int) -> CollectionViewCellItem?
    func sizeForCell(at index: Int, in collectionView: UICollectionView) -> CGSize
}
