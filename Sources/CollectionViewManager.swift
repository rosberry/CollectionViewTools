//
//  CollectionViewManager.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

open class CollectionViewManager: NSObject {
    
    public typealias SectionItem = CollectionViewSectionItem
    public typealias CellItem = CollectionViewCellItem
    public typealias ReusableViewItem = CollectionViewReusableViewItem
    public typealias Completion = (Bool) -> Void
    
    /// `UICollectionView` object for managing
    public unowned let collectionView: UICollectionView
    
    /// The methods declared by the UIScrollViewDelegate protocol allow the adopting delegate to respond to messages
    /// from the UIScrollView class and thus respond to, and in some affect, operations such as scrolling, zooming,
    /// deceleration of scrolled content, and scrolling animations.
    public weak var scrollDelegate: UIScrollViewDelegate?
    
    /// Set this handler to update your data after moving cells in collection view.
    /// Do not forget to update cell item's index path or section's index.
    ///
    /// - Parameters:
    ///    - collectionView: collection view where move action finished
    ///    - sourceIndexPath: source index path
    ///    - destinationIndexPath: destination index path
    public var moveItemsHandler: ((_ collectionView: UICollectionView,
                                   _ sourceIndexPath: IndexPath,
                                   _ destinationIndexPath: IndexPath) -> Void)?
    
    /// Use this property instead of `sectionItems` internally to avoid every time reload during update operations.
    internal var _sectionItems = [CollectionViewSectionItem]()
    
    /// Array of `CollectionViewSectionItem` objects, which respond for configuration of specified section in collection view.
    /// Setting this property leads collection view to reload data. If you don't need this behaviour use update methods instead.
    public var sectionItems: [CollectionViewSectionItem] {
        get {
            return _sectionItems
        }
        set {
            update(newValue, shouldReloadData: true, completion: nil)
        }
    }
    
    // MARK: Life cycle
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            self.collectionView.prefetchDataSource = self
        }
    }
    
    // MARK: - Subscripts
    
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
    
    // MARK: - Common methods
    
    /// Reloads cells, associated with passed cell items.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to reload
    ///   - completion: A closure that either specifies any additional actions which should be performed after reloading.
    open func reloadCellItems(_ cellItems: [CellItem], completion: Completion? = nil) {
        let indexPaths: [IndexPath] = cellItems.compactMap { cellItem in
            return cellItem.indexPath
        }
        perform(updates: { collectionView in
            collectionView?.reloadItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Scrolls through the collection view until a cell, associated with passed cell item is at a particular location on the screen.
    /// Invoking this method does not cause the delegate to receive a scrollViewDidScroll(_:) message, as is normal for programmatically
    /// invoked user interface operations.
    ///
    /// - Parameters:
    ///   - cellItem: `CollectionViewCellItem` object, that responds for configuration of cell at the specified index path.
    ///   - scrollPosition: A constant that identifies a relative position in the collection view (top, middle, bottom) for item when
    /// scrolling concludes. See UICollectionViewScrollPosition for descriptions of valid constants.
    ///   - animated: true if you want to animate the change in position; false if it should be immediate.
    open func scroll(to cellItem: CellItem, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = true) {
        if let indexPath = cellItem.indexPath {
            collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
        else {
            printContextWarning("It is impossible to scroll to cellItem \(cellItem)" +
                                        "because indexPath isn't set")
        }
    }
    
    // MARK: - Helpers
    
    /// Returns the cell item at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the item in the collection view.
    /// - Returns: A cell item associated with cell of the collection, or nil if the cell item
    /// wasn't added to manager or indexPath is out of range.
    open func cellItem(for indexPath: IndexPath) -> CellItem? {
        guard let sectionItem = sectionItem(for: indexPath), sectionItem.cellItems.count > indexPath.row else {
            return nil
        }

        return sectionItem.cellItems[indexPath.row]
    }

    /// Returns the reusable view item at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the item in the collection view.
    /// - Returns: A reusable view item associated with reusable view of the collection, or nil if the view item
    /// wasn't added to manager or indexPath is out of range.
    open func reusableViewItem(for indexPath: IndexPath, and kind: String) -> CollectionViewReusableViewItem? {
        guard let sectionItem = sectionItem(for: indexPath),
            sectionItem.reusableViewItems.count > indexPath.row else {
            return nil
        }
        let reusableViewItem = sectionItem.reusableViewItems[indexPath.row]
        guard reusableViewItem.type.kind == kind else {
            return nil
        }
        return reusableViewItem
    }
    
    /// Returns the section item at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the section in the collection view.
    /// - Returns: A section item associated with section of the collection, or nil if the section item
    /// wasn't added to manager or indexPath.section is out of range.
    open func sectionItem(for indexPath: IndexPath) -> SectionItem? {
        guard _sectionItems.count > indexPath.section else {
            return nil
        }

        return _sectionItems[indexPath.section]
    }
    
    /// Use this method if you need to set new section items.
    /// This method invokes register methods.
    /// - Parameters:
    ///   - sectionItems: Array of `CollectionViewSectionItem` objects, which respond for configuration of specified section in
    //// collection view.
    ///   - shouldReloadData: Set this parameter to true will invoke reloadData of the collection view.
    ///   - completion: Will be called after reload data is finished.
    open func update(_ sectionItems: [CollectionViewSectionItem], shouldReloadData: Bool, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0, animations: {
            self._sectionItems = sectionItems
            self.registerSectionItems()
            if shouldReloadData {
                self.collectionView.reloadData()
            }
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: - Registration
    
    /// Use this function to force cells and reusable views registration process if you override add/replace/reload methods
    /// Also in this method section item got set collection view and perform setting index paths and section item for cell items.
    /// So pay attention to the order of operations for section items updates methods. Set correct index for section item first.
    /// And don't forget to set `sectionItem` property for cell items.
    ///
    /// - Parameter sectionItem: The section item with cell items which need to be registered
    open func register(_ sectionItem: CollectionViewSectionItem) {
        sectionItem.collectionView = collectionView
        for index in 0..<sectionItem.cellItems.count {
            let cellItem = sectionItem.cellItems[index]
            if let sectionIndex = sectionItem.index {
                cellItem.indexPath = IndexPath(row: index, section: sectionIndex)
            }
            else {
                printContextWarning("It is impossible to setup indexPath to cellItem \(cellItem) " +
                                            "because there is no index in sectionItem \(sectionItem)")
            }
            cellItem.sectionItem = sectionItem
            register(cellItem)
        }
        for index in 0..<sectionItem.reusableViewItems.count {
            let reusableViewItem = sectionItem.reusableViewItems[index]
            register(reusableViewItem)
        }
    }
    
    /// Use this function to force cells registration process if you override add/replace/reload methods
    ///
    /// - Parameter cellItem: The cell item which need to be registered
    open func register(_ cellItem: CellItem) {
        cellItem.collectionView = collectionView
        collectionView.registerCell(with: cellItem.reuseType)
    }

    /// Use this function to force suplemented views registration process if you override add/replace/reload methods
    ///
    /// - Parameter viewItem: The view item which need to be registered
    open func register(_ reusableViewItem: ReusableViewItem) {
        reusableViewItem.collectionView = collectionView
        collectionView.registerView(with: reusableViewItem.reuseType, kind: reusableViewItem.type.kind)
    }
    
    // MARK: - Index paths
    
    /// Use this function to force update all indexes and index paths
    /// for section items and cell items during custom update operations.
    open func recalculateIndexPaths() {
        for index in 0..<_sectionItems.count {
            let sectionItem = _sectionItems[index]
            sectionItem.index = index
            recalculateIndexPaths(in: sectionItem)
        }
    }
    
    /// Use this function to force update all index paths for all cell items in specific section item during custom update operations.
    ///
    /// - Parameter sectionItem: The section item with cell items needed to recalculate index paths.
    open func recalculateIndexPaths(in sectionItem: CollectionViewSectionItem) {
        for index in 0..<sectionItem.cellItems.count {
            let cellItem = sectionItem.cellItems[index]
            if let sectionIndex = sectionItem.index {
                cellItem.indexPath = IndexPath(row: index, section: sectionIndex)
            }
            else {
                printContextWarning("It is impossible to setup indexPath to cellItem \(cellItem) " +
                                            "because there is no index in sectionItem \(sectionItem)")
            }
        }
    }
    
    /// Use this function to force update indexes for all section
    /// items and inner cell items during custom update operations.
    open func recalculateIndexes() {
        for section in 0..<_sectionItems.count {
            let sectionItem = _sectionItems[section]
            sectionItem.index = section
            
            for row in 0..<sectionItem.cellItems.count {
                let cellItem = sectionItem.cellItems[row]
                cellItem.indexPath = IndexPath(row: row, section: section)
                cellItem.sectionItem = sectionItem
            }
        }
    }
    
    // MARK: - Updates for cell items
    
    /// Replaces all cell items which are contained in specified section item with new cell items, and then replaces cells
    /// at the corresponding index paths of collection view.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to set, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be set
    ///   - completion: A closure that either specifies any additional actions which should be performed after setting.
    open func replaceAllCellItems(in sectionItem: SectionItem, with cellItems: [CellItem], completion: Completion? = nil) {
        guard let sectionIndex = sectionItem.index else {
            return
        }
        
        perform(updates: { collectionView in
            sectionItem.cellItems = cellItems
            register(sectionItem)
            collectionView?.reloadSections([sectionIndex])
        }, completion: completion)
    }
    
    /// Inserts cell items to the specified section item, and then inserts cells
    /// at the locations identified by array of corresponding index paths.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to insert, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be inserted
    ///   - indexes: An array of locations, that contains indexes of positions where specified cell items should be inserted
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func insert(_ cellItems: [CellItem], to sectionItem: SectionItem, at indexes: [Int], completion: Completion? = nil) {
        perform(updates: { [weak self] collectionView in
            for (cellItem, index) in zip(cellItems, indexes) {
                register(cellItem)
                sectionItem.cellItems.insert(cellItem, at: index)
                cellItem.sectionItem = sectionItem
            }
            self?.recalculateIndexPaths(in: sectionItem)
            
            let indexPaths: [IndexPath] = cellItems.compactMap { cellItem in
                return cellItem.indexPath
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
        insert(cellItems,
               to: sectionItem,
               at: Array(sectionItem.cellItems.count..<sectionItem.cellItems.count + cellItems.count),
               completion: completion)
    }
    
    /// Inserts cell items to the specified section item, and then inserts cells at the beginning of the section.
    ///
    /// - Parameters:
    ///   - cellItems: An array of cell items to insert, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be inserted
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func prepend(_ cellItems: [CellItem], to sectionItem: SectionItem, completion: Completion? = nil) {
        insert(cellItems, to: sectionItem, at: Array(0..<cellItems.count), completion: completion)
    }
    
    /// Replaces cell items inside the specified section item, and then replaces corresponding cells within section.
    ///
    /// - Parameters:
    ///   - indexes: An array of locations, that contains indexes of cell items to replace inside specified section item
    ///   - cellItems: An array of replacement cell items, which respond for cell configuration at specified index path
    ///   - sectionItem: Section item within which cell items should be replaced
    ///   - completion: A closure that either specifies any additional actions which should be performed after replacing.
    open func replace(cellItemsAt indexes: [Int], with cellItems: [CellItem], in sectionItem: SectionItem, completion: Completion? = nil) {
        guard indexes.count > 0 else {
            return
        }
        
        guard let section = sectionItem.index else {
            printContextWarning("It is impossible to replace cell items in sectionItem \(sectionItem)" +
                                        "because there is no index in it")
            return
        }
        
        perform(updates: { [weak self] collectionView in
            for index in 0..<cellItems.count {
                let cellItem = cellItems[index]
                register(cellItem)
                cellItem.sectionItem = sectionItem
            }
            if indexes.count == cellItems.count {
                for (cellItem, index) in zip(cellItems, indexes) {
                    sectionItem.cellItems[index] = cellItem
                    cellItem.indexPath = IndexPath(row: index, section: section)
                }
                let indexPaths: [IndexPath] = indexes.map { index in
                    return .init(row: index, section: section)
                }
                collectionView?.reloadItems(at: indexPaths)
            }
            else {
                var removeIndexPaths: [IndexPath] = []
                let firstIndex = indexes[0]
                for index in indexes.sorted(by: >) {
                    sectionItem.cellItems.remove(at: index)
                    removeIndexPaths.append(.init(row: index, section: section))
                }
                
                let insertIndexPaths: [IndexPath] = Array(firstIndex..<firstIndex + cellItems.count).map { index in
                    return .init(row: index, section: section)
                }
                sectionItem.cellItems.insert(contentsOf: cellItems, at: firstIndex)
                
                self?.recalculateIndexPaths(in: sectionItem)
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
        perform(updates: { [weak self] collectionView in
            let indexPaths = cellItems.compactMap { cellItem in
                return cellItem.indexPath
            }
            for indexPath in indexPaths.sorted(by: >) {
                _sectionItems[indexPath.section].cellItems.remove(at: indexPath.row)
            }
            
            self?.recalculateIndexPaths()
            collectionView?.deleteItems(at: indexPaths)
        }, completion: completion)
    }
    
    /// Removes cell items, that are preserved at specified indexes inside section item,
    /// and then removes cells at the corresponding locations.
    ///
    /// - Parameters:
    ///   - cellItems: Cell items to remove
    ///   - sectionItem: Section item that contains cell items to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func removeCellItems(at indexes: [Int], from sectionItem: SectionItem, completion: Completion? = nil) {
        perform(updates: { [weak self] collectionView in
            let indexPaths: [IndexPath] = indexes.compactMap { index in
                if let sectionIndex = sectionItem.index {
                    return .init(row: index, section: sectionIndex)
                }
                else {
                    printContextWarning("It is impossible to setup indexPath to cellItem \(cellItem) " +
                                                "because there is no index in sectionItem \(sectionItem)")
                    return nil
                }
            }
            
            for index in indexes.sorted(by: >) {
                sectionItem.cellItems.remove(at: index)
            }
            
            self?.recalculateIndexPaths(in: sectionItem)
            collectionView?.deleteItems(at: indexPaths)
        }, completion: completion)
    }
    
    // MARK: - Section items
    
    /// Inserts one or more section items.
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view.
    /// If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func insert(_ sectionItems: [CollectionViewSectionItem], at indexes: [Int], completion: Completion? = nil) {
        perform(updates: { [weak self] collectionView in
            for (sectionItem, index) in zip(sectionItems, indexes) {
                _sectionItems.insert(sectionItem, at: index)
            }
            self?.recalculateIndexes()
            for section in 0..<sectionItems.count {
                let sectionItem = sectionItems[section]
                register(sectionItem)
            }
            
            collectionView?.insertSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    /// Inserts one or more section items to the end of the collection view
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view.
    /// If a section already exists at the specified index location, it is moved down one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after insertion.
    open func append(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        insert(sectionItems, at: Array(_sectionItems.count..<_sectionItems.count + sectionItems.count), completion: completion)
    }
    
    /// Inserts one or more section items to the beginning of the collection view
    ///
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to insert
    ///   - indexes: An array of locations that specifies the sections to insert in the collection view.
    /// If a section already exists at the specified index location, it is moved down one index location.
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
        
        perform(updates: { [weak self] collectionView in
            if indexes.count == sectionItems.count {
                for (sectionItem, index) in zip(sectionItems, indexes) {
                    _sectionItems[index] = sectionItem
                    sectionItem.index = index
                    register(sectionItem)
                }
                collectionView?.reloadSections(IndexSet(indexes))
            }
            else {
                let firstIndex = indexes[0]
                for index in indexes.sorted(by: >) {
                    _sectionItems.remove(at: index)
                }
                
                _sectionItems.insert(contentsOf: sectionItems, at: firstIndex)
                self?.recalculateIndexes()
                
                for index in 0..<sectionItems.count {
                    let sectionItem = sectionItems[index]
                    register(sectionItem)
                }
                
                collectionView?.deleteSections(.init(indexes))
                collectionView?.insertSections(.init(firstIndex..<firstIndex + sectionItems.count))
            }
        }, completion: completion)
    }
    
    /// Removes one or more section items. Be sure that `CollectionViewManager` contains section items.
    /// - Parameters:
    ///   - sectionItems: An array of `CollectionViewSectionItem` objects to remove
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(_ sectionItems: [CollectionViewSectionItem], completion: Completion? = nil) {
        let indexes = sectionItems.compactMap { sectionItem in
            return _sectionItems.firstIndex { element in
                element === sectionItem
            }
        }
        remove(sectionItemsAt: indexes, completion: completion)
    }
    
    /// Removes one or more section items at specified indexes.
    /// - Parameters:
    ///   - indexes: An array of locations that specifies the sections to remove.
    /// If a section exists after the specified index location, it is moved up by one index location.
    ///   - completion: A closure that either specifies any additional actions which should be performed after removing.
    open func remove(sectionItemsAt indexes: [Int], completion: Completion? = nil) {
        perform(updates: { [weak self] collectionView in
            for index in indexes {
                _sectionItems.remove(at: index)
            }
            self?.recalculateIndexes()
            collectionView?.deleteSections(IndexSet(indexes))
        }, completion: completion)
    }
    
    // MARK: - Private
    
    /// Special wrapper for more convenient collection view updates.
    private func perform(updates: (UICollectionView?) -> Void, completion: Completion?) {
        collectionView.performBatchUpdates({ [weak collectionView] in
                                               updates(collectionView)
                                           }, completion: completion)
    }
    
    /// Use this method to perform register and set indexes operations for all section items.
    private func registerSectionItems() {
        for index in 0..<_sectionItems.count {
            let sectionItem = _sectionItems[index]
            sectionItem.index = index
            register(sectionItem)
        }
    }
}
