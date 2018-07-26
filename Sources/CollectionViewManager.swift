//
//  CollectionViewManager.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class CollectionViewManager: NSObject {
    
    public typealias SectionItem = CollectionViewSectionItem
    public typealias CellItem = CollectionViewCellItem
    public typealias Completion = (Bool) -> Void
    
    /// `UICollectionView` object for managing
    public unowned let collectionView: UICollectionView
    
    /// The methods declared by the UIScrollViewDelegate protocol allow the adopting delegate to respond to messages from the UIScrollView class and thus respond to, and in some affect, operations such as scrolling, zooming, deceleration of scrolled content, and scrolling animations.
    public weak var scrollDelegate: UIScrollViewDelegate?
    
    /// The property that determines whether should be used data source prefetching. Prefetching allowed only on iOS versions greater than or equal to 10.0
    public var isPrefetchingEnabled = false {
        didSet {
            if isPrefetchingEnabled {
                if #available(iOS 10.0, *) {
                    self.collectionView.prefetchDataSource = self
                }
                else {
                    fatalError("Prefetching allowed only on iOS versions greater than or equal to 10.0")
                }
            }
        }
    }
    
    /// Set this handler to update your data after moving cells in collection view.
    ///
    /// - Parameters:
    ///    - collectionView: collection view where move action finished
    ///    - sourceIndexPath: source index path
    ///    - destinationIndexPath: destination index path
    public var moveItemsHandler: ((_ collectionView: UICollectionView,
                                   _ sourceIndexPath: IndexPath,
                                   _ destinationIndexPath: IndexPath) -> Void)?
    
    internal var _sectionItems = [CollectionViewSectionItem]() {
        didSet {
            _sectionItems.forEach { register($0) }
        }
    }
    
    /// Array of `CollectionViewSectionItemProtocol` objects, which respond for configuration of specified section in collection view.
    public var sectionItems: [CollectionViewSectionItem] {
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
    
    /// Accesses the section item at the specified position.
    ///
    /// - Parameter index: The index of the section item to access.
    public subscript(index: Int) -> CollectionViewSectionItem? {
        guard index < _sectionItems.count else { return nil }
        return _sectionItems[index]
    }
    
    /// Accesses the cell item in the specified section and at the specified position.
    ///
    /// - Parameter indexPath: The index path of the cell item to access.
    public subscript(indexPath: IndexPath) -> CellItem? {
        return cellItem(for: indexPath)
    }
    
    /// Reloads cells, associated with passed cell items inside specified section, associated with passed section item
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to reload
    ///   - sectionItem: Section item that contains cell items to reload
    ///   - completion: A closure that either specifies any additional actions which should be performed after reloading.
    open func reloadCellItems(_ cellItems: [CellItem],
                              inSectionItem sectionItem: CollectionViewSectionItem,
                              completion: Completion? = nil) {
        let section = sectionItems.index(where: {$0 === sectionItem})!
        var indexPaths = [IndexPath]()
        
        for cellItem in cellItems {
            guard let item = sectionItem.cellItems.index(where: {$0 === cellItem}) else {
                fatalError("Unable to reload cell items that are not contained in section item.")
            }
            indexPaths.append(IndexPath(item: item, section: section))
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Scrolls through the collection view until a cell, associated with passed cell item is at a particular location on the screen.
    /// Invoking this method does not cause the delegate to receive a scrollViewDidScroll(_:) message, as is normal for programmatically invoked user interface operations.
    ///
    /// - Parameters:
    ///   - cellItem: `CollectionViewCellItemProtocol` object, that responds for configuration of cell at the specified index path.
    ///   - sectionItem: `CollectionViewSectionItemProtocol` object, that contains passed cell item
    ///   - scrollPosition: A constant that identifies a relative position in the collection view (top, middle, bottom) for item when scrolling concludes. See UICollectionViewScrollPosition for descriptions of valid constants.
    ///   - animated: true if you want to animate the change in position; false if it should be immediate.
    open func scroll(to cellItem: CellItem,
                     in sectionItem: SectionItem,
                     at scrollPosition: UICollectionViewScrollPosition,
                     animated: Bool = true) {
        let optionalSectionIndex = _sectionItems.index { $0 === sectionItem }
        let optionalCellIndex = sectionItem.cellItems.index { $0 === cellItem }
        guard let sectionIndex = optionalSectionIndex,
            let cellIndex = optionalCellIndex else { return }
        let indexPath = IndexPath(item: cellIndex, section: sectionIndex)
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    // MARK: - Helpers
    
    /// Returns the cell item at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the item in the collection view.
    /// - Returns: A cell item associated with cell of the collection, or nil if the cell item wasn't added to manager or indexPath is out of range.
    open func cellItem(for indexPath: IndexPath) -> CellItem? {
        if let cellItems = self.sectionItem(for: indexPath)?.cellItems {
            if indexPath.row < cellItems.count {
                return cellItems[indexPath.row]
            }
        }
        return nil
    }
    
    /// Returns the section item at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the section in the collection view.
    /// - Returns: A section item associated with section of the collection, or nil if the section item wasn't added to manager or indexPath.section is out of range.
    open func sectionItem(for indexPath: IndexPath) -> SectionItem? {
        if indexPath.section < _sectionItems.count {
            return _sectionItems[indexPath.section]
        }
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func register(_ sectionItem: CollectionViewSectionItem) {
        sectionItem.cellItems.forEach { register($0) }
        sectionItem.reusableViewItems.forEach { $0.register(for: collectionView) }
    }
    
    fileprivate func register(_ cellItem: CellItem) {
        collectionView.register(by: cellItem.reuseType)
    }
}

// MARK: - Batch updates for cell items
extension CollectionViewManager {

    /// Replaces all cell items which are contained in specified section item with new cell items, and then replaces cells at the corresponding index paths of collection view.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to set, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be setted
    ///   - completion: A closure that either specifies any additional actions which should be performed after setting.
    open func set(_ cellItems: [CellItem], to sectionItem: SectionItem, completion: Completion? = nil) {
        cellItems.forEach { cellItem in
            register(cellItem)
        }
        sectionItem.cellItems = cellItems
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: completion)
    }
    
    /// Inserts cell items to the specified section item, and then inserts cells at the locations identified by array of corresponding index paths.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to insert, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be inserted
    ///   - indexes: An array of locations, that contains indexes of positions where specified cell items should be inserted
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
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
    
    /// Replaces cell items inside the specified section item, and then replaces corresponding cells within section.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations, that contains indexes of cell items to replace inside specified section item
    ///   - cellItems: An array of replacement cell items, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be replaced
    ///   - completion: A closure that either specifies any additional actions which should be performed after replacing.
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
    
    /// Removes cell items, that are contained inside specified section item, and then removes cells at the corresponding locations.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to remove
    ///   - sectionItem: Section item that contains cell items to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(_ cellItems: [CellItem], from sectionItem: SectionItem, completion: Completion? = nil) {
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!

        let indexPaths: [IndexPath] = cellItems.compactMap { cellItem in
            guard let row = sectionItem.cellItems.index(where: {$0 === cellItem}) else {
                fatalError("Unable to remove cell item which is not contained in this section item.")
            }
            return IndexPath(item: row, section: sectionIndex)
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
            indexPaths.forEach { sectionItem.cellItems.remove(at: $0.row) }
        }, completion: completion)
    }
    
    /// Removes cell items, that are preserved at specified indexes inside section item, and then removes cells at the corresponding locations.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations, that contains indexes of cell items to remove inside specified section item
    ///   - sectionItem: Section item that contains cell items to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(cellItemsAt indexes: [Int], from sectionItem: SectionItem, completion: Completion? = nil) {
        let sectionIndex = _sectionItems.index { $0 === sectionItem }!
        
        let indexPaths: [IndexPath] = indexes.compactMap { IndexPath(item: $0, section: sectionIndex) }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
            indexes.forEach { sectionItem.cellItems.remove(at: $0) }
        }, completion: completion)
    }

}

// MARK: - Batch updates for section items
extension CollectionViewManager {
    
    /// Inserts one or more section items.
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItemProtocol` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view. If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func insert(_ sectionItems: [CollectionViewSectionItem], at indexes: [Int], completion: Completion? = nil) {
        sectionItems.forEach { register($0) }
        zip(sectionItems, indexes).forEach { self._sectionItems.insert($0, at: $1) }
        
        collectionView.performBatchUpdates({
            self.collectionView.insertSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    /// Replaces one or more section items.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations that specifies the sections to replace in the collection view.
    ///   - sectionItems: An array of replacement `CollectionViewSectionItemProtocol` objects
    ///   - completion: A closure that either specifies any additional actions which should be performed after replacing.
    open func replace(sectionItemsAt indexes: [Int], with sectionItems: [SectionItem], completion: Completion? = nil) {
        precondition(indexes.count == sectionItems.count, "Count of indexes and count of replacement section items should be equal.")
        sectionItems.forEach { register($0) }
        zip(sectionItems, indexes).forEach { self._sectionItems[$1] = $0 }
        collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    /// Removes one or more section items. Be sure that `CollectionViewManager` contains section items.
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItemProtocol` objects to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        let indexes = sectionItems.compactMap { sectionItem in self._sectionItems.index { $0 === sectionItem } }
        indexes.forEach { self._sectionItems.remove(at: $0) }
        collectionView.deleteSections(IndexSet(indexes))
    }
    
    /// Removes one or more section items at spectified indexes.
    /// - Parameters:
    ///   - indexes: An array of locations that specifies the sections to remove. If a section exists after the specified index location, it is moved up by one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(sectionItemsAt indexes: [Int], completion: Completion? = nil) {
        indexes.forEach { self._sectionItems.remove(at: $0) }
        collectionView.performBatchUpdates({
            self.collectionView.deleteSections(IndexSet(indexes))
        }, completion: completion)
    }

}
