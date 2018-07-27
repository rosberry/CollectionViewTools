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
                    print("[ERROR] Prefetching allowed only on iOS versions >= 10.0")
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
            _sectionItems.forEach { sectionItem in
                register(sectionItem)
            }
        }
    }
    
    /// Array of `CollectionViewSectionItem` objects, which respond for configuration of specified section in collection view.
    public var sectionItems: [CollectionViewSectionItem] {
        get {
            return _sectionItems
        }
        set {
            //TODO: Fix every time reload
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
        guard (0..<_sectionItems.count).contains(index) else {
            return nil
        }
        return _sectionItems[index]
    }
    
    /// Accesses the cell item in the specified section and at the specified position.
    ///
    /// - Parameter indexPath: The index path of the cell item to access.
    public subscript(indexPath: IndexPath) -> CellItem? {
        return cellItem(for: indexPath)
    }
    
    /// Reloads cells, associated with passed cell items. If section item is nil this method search through all section items until found
    /// all cell items which should be reload. If you have concrete section item it might be more efficient to set it.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to reload
    ///   - sectionItem: Section item that contains cell items to reload
    ///   - completion: A closure that either specifies any additional actions which should be performed after reloading.
    open func reloadCellItems(_ cellItems: [CellItem],
                              inSectionItem sectionItem: CollectionViewSectionItem?,
                              completion: Completion? = nil) {
        var indexPaths: [IndexPath] = []
        if let sectionItem = sectionItem {
            guard let section = sectionItems.index(where: { element in
                element === sectionItem
            }) else {
                print("[ERROR] There are no sectionItem \(sectionItem) in sectionItems array")
                return
            }
            
            for cellItem in cellItems {
                guard let item = sectionItem.cellItems.index(where: { element in
                    element === cellItem
                }) else {
                    print("[ERROR] Unable to reload cell items that are not contained in section item")
                    return
                }
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        else {
            indexPaths = calculateIndexPaths(of: cellItems)
        }
        
        perform(updates: { collectionView in
            collectionView?.reloadItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Scrolls through the collection view until a cell, associated with passed cell item is at a particular location on the screen.
    /// Invoking this method does not cause the delegate to receive a scrollViewDidScroll(_:) message, as is normal for programmatically invoked user interface operations.
    /// If section item is nil this method tries to calculate index path by searching through all section items and cell items.
    ///
    /// - Parameters:
    ///   - cellItem: `CollectionViewCellItem` object, that responds for configuration of cell at the specified index path.
    ///   - sectionItem: `CollectionViewSectionItem` object, that contains passed cell item
    ///   - scrollPosition: A constant that identifies a relative position in the collection view (top, middle, bottom) for item when scrolling concludes. See UICollectionViewScrollPosition for descriptions of valid constants.
    ///   - animated: true if you want to animate the change in position; false if it should be immediate.
    open func scroll(to cellItem: CellItem,
                     in sectionItem: SectionItem?,
                     at scrollPosition: UICollectionViewScrollPosition,
                     animated: Bool = true) {
        var section: Int?
        if let index = _sectionItems.index(where: { element in
            return element === sectionItem
        }) {
            section = index
        }
        else {
            for (index, sectionItem) in _sectionItems.enumerated() where sectionItem.cellItems.contains(where: { element in
                return cellItem === element
            }) {
                section = index
            }
        }
        
        guard let sectionIndex = section,
              let cellIndex = _sectionItems[sectionIndex].cellItems.index(where: { element in
                  return element === cellItem
              }) else {
            print("[ERROR] Can't scroll to cell item \(cellItem) because manager isn't contains it")
            return
        }
        
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
    
    /// Returns the index of the section item if possible.
    ///
    /// - Parameter sectionItem: The section item which index must be found
    open func sectionIndex(for sectionItem: SectionItem) -> Int? {
        return _sectionItems.index { element in
            return element === sectionItem
        }
    }
    
    // MARK: - Registration
    
    /// Use this function to force cells and reusable views registration process if you override add/replace/reload methods
    ///
    /// - Parameter sectionItem: The section item with cell items which need to be registered
    open func register(_ sectionItem: CollectionViewSectionItem) {
        sectionItem.cellItems.forEach { cellItem in
            register(cellItem)
        }
        sectionItem.reusableViewItems.forEach { reusableViewItem in
            reusableViewItem.register(for: collectionView)
        }
    }
    
    /// Use this function to force cells registration process if you override add/replace/reload methods
    ///
    /// - Parameter cellItem: The cell item which need to be registered
    open func register(_ cellItem: CellItem) {
        collectionView.register(by: cellItem.reuseType)
    }
    
    // MARK: - Updates for cell items
    
    /// Replaces all cell items which are contained in specified section item with new cell items, and then replaces cells at the corresponding index paths of collection view.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to set, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be set
    ///   - completion: A closure that either specifies any additional actions which should be performed after setting.
    open func replaceAllCellItems(in sectionItem: SectionItem, with cellItems: [CellItem], completion: Completion? = nil) {
        guard let section = sectionIndex(for: sectionItem) else {
            return
        }
        
        perform(updates: { collectionView in
            cellItems.forEach { cellItem in
                register(cellItem)
            }
            sectionItem.cellItems = cellItems
            
            collectionView?.reloadSections([section])
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
        guard let section = sectionIndex(for: sectionItem) else {
            return
        }
        
        perform(updates: { collectionView in
            zip(cellItems, indexes).forEach { cellItem, index in
                register(cellItem)
                sectionItem.cellItems.insert(cellItem, at: index)
            }
            
            let indexPaths: [IndexPath] = indexes.map { index in
                return .init(row: index, section: section)
            }
            
            collectionView?.insertItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Inserts cell items to the specified section item, and then inserts cells at the end of the section.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to insert, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be inserted
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func append(_ cellItems: [CellItem], to sectionItem: SectionItem, completion: Completion? = nil) {
        insert(cellItems, to: sectionItem, at: Array(sectionItem.cellItems.count...cellItems.count), completion: completion)
    }
    
    /// Inserts cell items to the specified section item, and then inserts cells at the beginning of the section.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to insert, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be inserted
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func prepend(_ cellItems: [CellItem], to sectionItem: SectionItem, completion: Completion? = nil) {
        insert(cellItems, to: sectionItem, at: Array(0...cellItems.count), completion: completion)
    }
    
    /// Replaces cell items inside the specified section item, and then replaces corresponding cells within section.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations, that contains indexes of cell items to replace inside specified section item
    ///   - cellItems: An array of replacement cell items, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be replaced
    ///   - completion: A closure that either specifies any additional actions which should be performed after replacing.
    open func replace(cellItemsAt indexes: [Int], with cellItems: [CellItem], in sectionItem: SectionItem, completion: Completion? = nil) {
        guard let section = sectionIndex(for: sectionItem),
              indexes.count > 0 else {
            return
        }
        
        perform(updates: { collectionView in
            cellItems.forEach { cellItem in
                register(cellItem)
            }
            
            if indexes.count == cellItems.count {
                zip(cellItems, indexes).forEach { cellItem, index in
                    sectionItem.cellItems[index] = cellItem
                }
                let indexPaths: [IndexPath] = indexes.map { index in
                    return .init(row: index, section: section)
                }
                collectionView?.reloadItems(at: indexPaths)
            }
            else {
                var removeIndexPaths: [IndexPath] = []
                let firstIndex = indexes[0]
                indexes.sorted().reversed().forEach { index in
                    sectionItem.cellItems.remove(at: index)
                    removeIndexPaths.append(.init(row: index, section: section))
                }
                
                let insertIndexPaths: [IndexPath] = Array(firstIndex..<cellItems.count).map { index in
                    return .init(row: index, section: section)
                }
                sectionItem.cellItems.insert(contentsOf: cellItems, at: firstIndex)
                
                collectionView?.deleteItems(at: removeIndexPaths)
                collectionView?.insertItems(at: insertIndexPaths)
            }
        }, completion: completion)
    }
    
    /// Removes cell items and then removes cells at the corresponding locations.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(_ cellItems: [CellItem], completion: Completion? = nil) {
        perform(updates: { collectionView in
            let indexPaths = calculateIndexPaths(of: cellItems)
            indexPaths.sorted().reversed().forEach { indexPath in
                sectionItems[indexPath.section].cellItems.remove(at: indexPath.row)
            }
            collectionView?.deleteItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Removes cell items, that are preserved at specified indexes inside section item, and then removes cells at the corresponding locations.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to remove
    ///   - sectionItem: Section item that contains cell items to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func removeCellItems(at indexes: [Int], from sectionItem: SectionItem, completion: Completion? = nil) {
        guard let section = sectionIndex(for: sectionItem) else {
            return
        }
        
        perform(updates: { collectionView in
            let indexPaths: [IndexPath] = indexes.map { index in
                return .init(row: index, section: section)
            }
            
            indexes.sorted().reversed().forEach { index in
                sectionItem.cellItems.remove(at: index)
            }
            
            collectionView?.deleteItems(at: indexPaths)
        }, completion: completion)
    }
    
    // MARK: - Section items
    
    /// Inserts one or more section items.
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view. If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func insert(_ sectionItems: [CollectionViewSectionItem], at indexes: [Int], completion: Completion? = nil) {
        perform(updates: { collectionView in
            sectionItems.forEach { sectionItem in
                register(sectionItem)
            }
            zip(sectionItems, indexes).forEach { sectionItem, index in
                _sectionItems.insert(sectionItem, at: index)
            }
            
            collectionView?.insertSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    /// Inserts one or more section items to the end of the collection view
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view. If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func append(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        insert(sectionItems, at: Array(self.sectionItems.count..<sectionItems.count), completion: completion)
    }
    
    /// Inserts one or more section items to the beginning of the collection view
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view. If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func prepend(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        insert(sectionItems, at: Array(0..<sectionItems.count), completion: completion)
    }
    
    /// Replaces one or more section items.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations that specifies the sections to replace in the collection view.
    ///   - sectionItems: An array of replacement `CollectionViewSectionItem` objects
    ///   - completion: A closure that either specifies any additional actions which should be performed after replacing.
    open func replace(sectionItemsAt indexes: [Int], with sectionItems: [SectionItem], completion: Completion? = nil) {
        guard indexes.count > 0 else {
            return
        }
        perform(updates: { collectionView in
            if indexes.count == sectionItems.count {
                sectionItems.forEach { sectionItem in
                    register(sectionItem)
                }
                zip(sectionItems, indexes).forEach { sectionItem, index in
                    _sectionItems[index] = sectionItem
                }
                collectionView?.reloadSections(IndexSet(indexes))
            }
            else {
                let firstIndex = indexes[0]
                indexes.sorted().reversed().forEach { index in
                    _sectionItems.remove(at: index)
                }
                
                collectionView?.deleteSections(.init(indexes))
                collectionView?.insertSections(.init(firstIndex..<sectionItems.count))
            }
        }, completion: completion)
    }
    
    /// Removes one or more section items. Be sure that `CollectionViewManager` contains section items.
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        let indexes = sectionItems.compactMap { sectionItem in
            return _sectionItems.index { element in
                element === sectionItem
            }
        }
        remove(sectionItemsAt: indexes, completion: completion)
    }
    
    /// Removes one or more section items at spectified indexes.
    /// - Parameters:
    ///   - indexes: An array of locations that specifies the sections to remove. If a section exists after the specified index location, it is moved up by one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(sectionItemsAt indexes: [Int], completion: Completion? = nil) {
        perform(updates: { collectionView in
            indexes.forEach { index in
                _sectionItems.remove(at: index)
            }
            collectionView?.deleteSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    // MARK: - Private
    
    private func perform(updates: (UICollectionView?) -> Void, completion: Completion?) {
        collectionView.performBatchUpdates({ [weak collectionView] in
                                               updates(collectionView)
                                           }, completion: completion)
    }
    
    private func calculateIndexPaths(of cellItems: [CellItem]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        outer: for (sectionIndex, sectionItem) in sectionItems.enumerated() {
            for (cellIndex, cellItem) in sectionItem.cellItems.enumerated() where cellItems.contains(where: { element in
                return cellItem === element
            }) {
                indexPaths.append(.init(row: cellIndex, section: sectionIndex))
                if indexPaths.count == cellItems.count {
                    break outer
                }
            }
        }
        return indexPaths
    }
}
