//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class LazyCollectionViewSectionItem: CollectionViewSectionItem {

    var cellItemsDictionary: [Int: CollectionViewCellItem] = [:]

    open var cellItems: [CollectionViewCellItem] {
        get {
            Array(cellItemsDictionary.values)
        }
        set {
            cellItemsDictionary = [:]
            newValue.enumerated().forEach { index, cellItem in
                cellItemsDictionary[index] = cellItem
            }
        }
    }

    open var reusableViewItems: [CollectionViewReusableViewItem]

    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero

    public init(cellItems: [CollectionViewCellItem] = [], reusableViewItems: [CollectionViewReusableViewItem] = []) {
        self.reusableViewItems = reusableViewItems
        self.cellItems = cellItems
    }
}
