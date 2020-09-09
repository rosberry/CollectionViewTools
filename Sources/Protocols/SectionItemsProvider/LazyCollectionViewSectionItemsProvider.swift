//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

open class LazyCollectionViewSectionItemsProvider: BaseCollectionViewSectionItemsProvider {

    public var cellItemsNumberHandler: (Int) -> Int
    public var makeCellItemHandler: (IndexPath) -> CollectionViewCellItem

    init(reuseTypes: [ReuseType],
         cellItemsNumberHandler: @escaping (Int) -> Int,
         makeCellItemHandler: @escaping (IndexPath) -> CollectionViewCellItem) {
        self.cellItemsNumberHandler = cellItemsNumberHandler
        self.makeCellItemHandler = makeCellItemHandler
        super.init()
        self.sectionItems = sectionItems
        self.reuseTypes = reuseTypes
    }

    public override subscript(indexPath: IndexPath) -> CollectionViewCellItem? {
        get {
            let sectionItem = sectionItems[indexPath.section]
            if let cellItem = sectionItem.diffCellItems[safe: indexPath.row] {
                return cellItem
            }
            let cellItem = makeCellItemHandler(indexPath)
            sectionItem.cellItems[indexPath.row] = cellItem
            return cellItem
        }
        set {
            if let cellItem = newValue {
                sectionItems[indexPath.section].cellItems[indexPath.row] = cellItem
            }
            else {
                sectionItems[indexPath.section].cellItems.remove(at: indexPath.row)
            }
        }
    }

    public override func numberOfItems(inSection section: Int) -> Int {
        cellItemsNumberHandler(section)
    }
}
