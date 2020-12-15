//
//  CollectionViewManager.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol SectionItemsProvider {

    var numberOfSections: Int { get }
    var sectionItems: [CollectionViewSectionItem] { get set}
    var isEmpty: Bool { get }
    subscript(index: Int) -> CollectionViewSectionItem? { get set }
    subscript(indexPath: IndexPath) -> CollectionViewCellItem? { get set }
    func removedCellItem(at indexPath: IndexPath) -> CollectionViewCellItem?
    func numberOfItems(inSection: Int) -> Int
    func sizeForCellItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGSize

    func insert(_ sectionItem: CollectionViewSectionItem, at index: Int)
    func insert(contentsOf collection: [CollectionViewSectionItem], at index: Int)
    func remove(at index: Int)
    func remove(at indexPath: IndexPath)
    func move(sectionItem: CollectionViewSectionItem?, at index: Int, to destinationIndex: Int)
    func move(cellItemAt indexPath: IndexPath, to destinationIndexPath: IndexPath)
    func firstIndex(of: CollectionViewSectionItem) -> Int?
    func forEachCellItem(actionHandler: (Int, CollectionViewCellItem) -> Void)
    func registerIfNeeded(cellItem: CollectionViewCellItem)
    func registerKnownReuseTypes(in collectionView: UICollectionView)
}
