//
//  CollectionViewManager.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class CollectionViewManager: NSObject {
    
    public typealias SectionItem = CollectionViewSectionItemProtocol
    public typealias CellItem = CollectionViewCellItemProtocol
    public typealias Completion = (Bool) -> Void
    
    public unowned let collectionView: UICollectionView
    public weak var scrollDelegate: UIScrollViewDelegate?
    
    internal var _sectionItems = [SectionItem]() {
        didSet {
            sectionItems.forEach { register($0) }
        }
    }
    public var sectionItems: [SectionItem] {
        get {
            return _sectionItems
        }
        set {
            _sectionItems = newValue
            collectionView.reloadData()
        }
    }
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            self.collectionView.prefetchDataSource = self
        }
    }
    
    open func scroll(to cellItem: CellItem,
                     in sectionItem: SectionItem,
                     at scrollPosition: UICollectionViewScrollPosition, animated: Bool = true) {
        let optionalSectionIndex = _sectionItems.index { $0 === sectionItem }
        let optionalCellIndex = sectionItem.cellItems.index { $0 === cellItem }
        guard let sectionIndex = optionalSectionIndex,
            let cellIndex = optionalCellIndex else { return }
        let indexPath = IndexPath(item: cellIndex, section: sectionIndex)
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    // MARK: - Helpers
    
    open func cellItem(for indexPath: IndexPath) -> CellItem? {
        if let cellItems = self.sectionItem(for: indexPath)?.cellItems {
            if indexPath.row < cellItems.count {
                return cellItems[indexPath.row]
            }
        }
        return nil
    }
    
    open func sectionItem(for indexPath: IndexPath) -> SectionItem? {
        if indexPath.section < _sectionItems.count {
            return sectionItems[indexPath.section]
        }
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func register(_ sectionItem: SectionItem) {
        sectionItem.cellItems.forEach { register($0) }
        sectionItem.reusableViewItems.forEach { $0.register(for: collectionView) }
    }
    
    fileprivate func register(_ cellItem: CellItem) {
        collectionView.register(by: cellItem.reuseType)
    }
}

// MARK: - Batch updates for cell items
extension CollectionViewManager {

    open func set(_ cellItems: [CellItem], to sectionItem: SectionItem) {
        cellItems.forEach { cellItem in
            register(cellItem)
        }
        sectionItem.cellItems = cellItems
        
        collectionView.reloadData()
    }
    
    open func insert(_ cellItems: [CellItem], to sectionItem: SectionItem, at indexes: [Int], completion: Completion? = nil) {
        zip(cellItems, indexes).forEach { cellItem, index in
            precondition(index <= sectionItem.cellItems.count,
                         "Unable to insert item at index that is larger than count of cell items in this section.")
            register(cellItem)
            sectionItem.cellItems.insert(cellItem, at: index)
        }
        
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!
        let indexPaths = indexes.map { IndexPath(item: $0, section: sectionIndex) }

        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexPaths)
        }, completion: completion)
    }
    
    open func replace(cellItemsAt indexes: [Int], with cellItems: [CellItem], in sectionItem: SectionItem, completion: Completion? = nil) {
        precondition(indexes.count == cellItems.count, "Count of indexes and count of replacement cell items should be equal.")
        cellItems.forEach { register($0) }
        zip(cellItems, indexes).forEach { sectionItem.cellItems[$1] = $0 }
        
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!
        let indexPaths = indexes.map { IndexPath(item: $0, section: sectionIndex) }
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: indexPaths)
        }, completion: completion)
    }
    
    open func remove(_ cellItems: [CellItem], from sectionItem: SectionItem, completion: Completion? = nil) {
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!

        let indexPaths: [IndexPath] = cellItems.flatMap { cellItem in
            guard let row = sectionItem.cellItems.index(where: {$0 === cellItem}) else {
                return nil
            }
            return IndexPath(item: row, section: sectionIndex)
        }
        
        cellItems.forEach { cellItem in
            guard let index = sectionItem.cellItems.index(where: { $0 === cellItem }) else {
                fatalError("Unable to remove cell item which is not contained in this section item.")
            }
            sectionItem.cellItems.remove(at: index)
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
        }, completion: completion)
    }
    
    open func remove(cellItemsAt indexes: [Int], from sectionItem: SectionItem, completion: Completion? = nil) {
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!
        indexes.forEach { sectionItem.cellItems.remove(at: $0) }
        
        let indexPaths: [IndexPath] = indexes.flatMap { IndexPath(item: $0, section: sectionIndex) }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
        }, completion: completion)
    }

}

// MARK: - Batch updates for section items
extension CollectionViewManager {
    
    open func insert(_ sectionItems: [SectionItem], at indexes: [Int], completion: Completion? = nil) {
        sectionItems.forEach { register($0) }
        zip(sectionItems, indexes).forEach { self._sectionItems.insert($0, at: $1) }
        
        collectionView.performBatchUpdates({
            self.collectionView.insertSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    open func replace(sectionItemsAt indexes: [Int], with sectionItems: [SectionItem]) {
        precondition(indexes.count == sectionItems.count, "Count of indexes and count of replacement section items should be equal.")
        sectionItems.forEach { register($0) }
        zip(sectionItems, indexes).forEach { self._sectionItems[$1] = $0 }
        self.collectionView.reloadSections(IndexSet(indexes))
    }
    
    open func remove(_ sectionItems: [SectionItem], completion: Completion? = nil) {
        let indexes = sectionItems.flatMap { sectionItem in self._sectionItems.index { $0 === sectionItem } }
        indexes.forEach { self._sectionItems.remove(at: $0) }
        collectionView.deleteSections(IndexSet(indexes))
    }
    
    open func remove(sectionItemsAt indexes: [Int], completion: Completion? = nil) {
        indexes.forEach { self._sectionItems.remove(at: $0) }
        collectionView.performBatchUpdates({
            self.collectionView.deleteSections(IndexSet(indexes))
        }, completion: completion)
    }

}
