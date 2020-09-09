//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol CollectionViewSectionItemsProvider {

    var numberOfSections: Int { get }
    var reuseTypes: [ReuseType] { get }
    var sectionItems: [CollectionViewSectionItem] { get set }
    subscript(index: Int) -> CollectionViewSectionItem { get set }
    subscript(indexPath: IndexPath) -> CollectionViewCellItem? { get set }
    func numberOfItems(inSection: Int) -> Int

    func insert(_ sectionItem: CollectionViewSectionItem, at index: Int)
    func insert(contentsOf collection: [CollectionViewSectionItem], at index: Int)
    func remove(at index: Int)
    func remove(at indexPath: IndexPath)
    func move(cellItemAt indexPath: IndexPath, to destinationIndexPath: IndexPath)
    func firstIndex(of: CollectionViewSectionItem) -> Int?
    func forEachCellItem(actionHandler: (Int, CollectionViewCellItem) -> Void)
}
