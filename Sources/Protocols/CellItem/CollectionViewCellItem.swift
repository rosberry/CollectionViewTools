//
//  CollectionViewCellItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView
import ObjectiveC.runtime

// MARK: - CollectionViewCellItem

public protocol CollectionViewCellItem: CollectionViewConfigureCellItem,
                                        CollectionViewReuseCellItem,
                                        CollectionViewSizeCellItem,
                                        CollectionViewGeneralCellItem,
                                        CollectionViewCellItemDataSource,
                                        CollectionViewSiblingCellItem {
    
}

// MARK: - CollectionViewReuseCellItem

public protocol CollectionViewReuseCellItem: AnyObject {
    var reuseType: ReuseType { get }
}

// MARK: - CollectionViewSizeCellItem

public protocol CollectionViewSizeCellItem: AnyObject {
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize
}

// MARK: - CollectionViewConfigureCellItem

public protocol CollectionViewConfigureCellItem: AnyObject {
    func configure(cell: UICollectionViewCell, at indexPath: IndexPath)
}

// MARK: - CollectionViewConfigureCellItem

public protocol CollectionViewSiblingCellItem: AnyObject {
    var collectionView: UICollectionView { get set }
}

extension CollectionViewSiblingCellItem {
    public var collectionView: UICollectionView {
        get {
            if let collectionView = objc_getAssociatedObject(self, &AssociatedKeys.collectionView) as? UICollectionView {
                return collectionView
            }
            fatalError("You should never get this error if you use collection view tools properly. " +
                               "The reason is that you create cell item and didn't set collection view")
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.collectionView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

// MARK: - CollectionViewGeneralCellItem

public typealias ActionHandler = ((UICollectionView, IndexPath) -> Void)
public typealias ActionResolver = ((UICollectionView, IndexPath) -> Bool)

public protocol CollectionViewGeneralCellItem: AnyObject {
    
    var itemShouldHighlightHandler: ActionResolver? { get set }
    var itemDidHighlightHandler: ActionHandler? { get set }
    var itemDidUnhighlightHandler: ActionHandler? { get set }
    
    var itemDidSelectHandler: ActionHandler? { get set }
    var itemDidDeselectHandler: ActionHandler? { get set }
    var itemShouldSelectHandler: ActionResolver? { get set }
    var itemShouldDeselectHandler: ActionResolver? { get set }
    
    var itemWillDisplayCellHandler: ActionHandler? { get set }
    var itemWillDisplayViewHandler: ActionHandler? { get set }
    var itemDidEndDisplayingCellHandler: ActionHandler? { get set }
    var itemDidEndDisplayingViewHandler: ActionHandler? { get set }
    
    var itemCanMoveHandler: ActionResolver? { get set }
    
    func shouldHighlight(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool
    func didHighlight(for collectionView: UICollectionView, at indexPath: IndexPath)
    func didUnhighlight(for collectionView: UICollectionView, at indexPath: IndexPath)
    
    func shouldSelect(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool
    func shouldDeselect(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool
    func didSelect(for collectionView: UICollectionView, at indexPath: IndexPath)
    func didDeselect(for collectionView: UICollectionView, at indexPath: IndexPath)
    
    func willDisplay(cell: UICollectionViewCell, for collectionView: UICollectionView, at indexPath: IndexPath)
    func willDisplay(view: UICollectionReusableView, for elementKind: String, for collectionView: UICollectionView, at indexPath: IndexPath)
    func didEndDisplaying(cell: UICollectionViewCell, for collectionView: UICollectionView, at indexPath: IndexPath)
    func didEndDisplaying(view: UICollectionReusableView,
                          for elementKind: String,
                          for collectionView: UICollectionView,
                          at indexPath: IndexPath)
    
    func canMove(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool
}

private enum AssociatedKeys {
    
    static var shouldHighlightHandler = "rsb_shouldHighlightHandler"
    static var didHighlightHandler = "rsb_didHighlightHandler"
    static var didUnhighlightHandler = "rsb_didUnhighlightHandler"
    static var didSelectHandler = "rsb_didSelectHandler"
    static var didDeselectHandler = "rsb_didDeselectHandler"
    static var shouldSelectHandler = "rsb_shouldSelectHandler"
    static var shouldDeselectHandler = "rsb_shouldDeselectHandler"
    static var willDisplayCellHandler = "rsb_willDisplayCellHandler"
    static var willDisplayViewHandler = "rsb_willDisplayViewHandler"
    static var didEndDisplayingCellHandler = "rsb_didEndDisplayingCellHandler"
    static var didEndDisplayingViewHandler = "rsb_didEndDisplayingViewHandler"
    static var canMoveHandler = "rsb_canMoveHandler"
    
    static var collectionView = "rsb_collectionView"
}

public extension CollectionViewGeneralCellItem {
    
    // MARK: - Handlers
    
    var itemShouldHighlightHandler: ActionResolver? {
        get {
            return ClosureWrapper<ActionResolver>.handler(for: self, key: &AssociatedKeys.shouldHighlightHandler)
        }
        set {
            ClosureWrapper<ActionResolver>.setHandler(newValue, for: self, key: &AssociatedKeys.shouldHighlightHandler)
        }
    }
    
    var itemDidHighlightHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didHighlightHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didHighlightHandler)
        }
    }
    
    var itemDidUnhighlightHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didUnhighlightHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didUnhighlightHandler)
        }
    }
    
    var itemDidSelectHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didDeselectHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didDeselectHandler)
        }
    }
    
    var itemDidDeselectHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didSelectHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didSelectHandler)
        }
    }
    
    var itemShouldSelectHandler: ActionResolver? {
        get {
            return ClosureWrapper<ActionResolver>.handler(for: self, key: &AssociatedKeys.shouldSelectHandler)
        }
        set {
            ClosureWrapper<ActionResolver>.setHandler(newValue, for: self, key: &AssociatedKeys.shouldSelectHandler)
        }
    }
    
    var itemShouldDeselectHandler: ActionResolver? {
        get {
            return ClosureWrapper<ActionResolver>.handler(for: self, key: &AssociatedKeys.shouldDeselectHandler)
        }
        set {
            ClosureWrapper<ActionResolver>.setHandler(newValue, for: self, key: &AssociatedKeys.shouldDeselectHandler)
        }
    }
    
    var itemWillDisplayCellHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.willDisplayCellHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.willDisplayCellHandler)
        }
    }
    
    var itemWillDisplayViewHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.willDisplayViewHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.willDisplayViewHandler)
        }
    }
    
    var itemDidEndDisplayingCellHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didEndDisplayingCellHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didEndDisplayingCellHandler)
        }
    }
    
    var itemDidEndDisplayingViewHandler: ActionHandler? {
        get {
            return ClosureWrapper<ActionHandler>.handler(for: self, key: &AssociatedKeys.didEndDisplayingViewHandler)
        }
        set {
            ClosureWrapper<ActionHandler>.setHandler(newValue, for: self, key: &AssociatedKeys.didEndDisplayingViewHandler)
        }
    }
    
    var itemCanMoveHandler: ActionResolver? {
        get {
            return ClosureWrapper<ActionResolver>.handler(for: self, key: &AssociatedKeys.canMoveHandler)
        }
        set {
            ClosureWrapper<ActionResolver>.setHandler(newValue, for: self, key: &AssociatedKeys.canMoveHandler)
        }
    }
    
    // MARK: - Functions
    
    func size(for collectionView: UICollectionView, with layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func shouldHighlight(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool {
        return itemShouldHighlightHandler?(collectionView, indexPath) ?? true
    }
    
    func didHighlight(for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemDidHighlightHandler?(collectionView, indexPath)
    }
    
    func didUnhighlight(for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemDidUnhighlightHandler?(collectionView, indexPath)
    }
    
    func shouldSelect(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool {
        return itemShouldSelectHandler?(collectionView, indexPath) ?? true
    }
    
    func shouldDeselect(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool {
        return itemShouldDeselectHandler?(collectionView, indexPath) ?? true
    }
    
    func didSelect(for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemDidSelectHandler?(collectionView, indexPath)
    }
    
    func didDeselect(for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemDidDeselectHandler?(collectionView, indexPath)
    }
    
    func willDisplay(cell: UICollectionViewCell, for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemWillDisplayCellHandler?(collectionView, indexPath)
    }
    
    func willDisplay(view: UICollectionReusableView,
                     for elementKind: String,
                     for collectionView: UICollectionView,
                     at indexPath: IndexPath) {
        itemWillDisplayViewHandler?(collectionView, indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, for collectionView: UICollectionView, at indexPath: IndexPath) {
        itemDidEndDisplayingCellHandler?(collectionView, indexPath)
    }
    
    func didEndDisplaying(view: UICollectionReusableView,
                          for elementKind: String,
                          for collectionView: UICollectionView,
                          at indexPath: IndexPath) {
        itemDidEndDisplayingViewHandler?(collectionView, indexPath)
    }
    
    func canMove(for collectionView: UICollectionView, at indexPath: IndexPath) -> Bool {
        return itemCanMoveHandler?(collectionView, indexPath) ?? false
    }
}
