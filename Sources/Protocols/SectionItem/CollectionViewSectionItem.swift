//
//  CollectionViewSectionItem.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView
import ObjectiveC.runtime

public protocol CollectionViewSectionItem: CollectionViewSiblingSectionItem {
    var cellItems: [CollectionViewCellItem] { get set }
    var reusableViewItems: [CollectionViewReusableViewItem] { get set }

    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
    var insets: UIEdgeInsets { get }
}

// MARK: - CollectionViewSiblingSectionItem

public protocol CollectionViewSiblingSectionItem: AnyObject {
    var collectionView: UICollectionView? { get set }
    var index: Int? { get set }
}

extension CollectionViewSiblingSectionItem {
    public var collectionView: UICollectionView? {
        get {
            if let object = objc_getAssociatedObject(self, &AssociatedKeys.collectionView) as? UICollectionView {
                return object
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.collectionView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public var index: Int? {
        get {
            if let object = objc_getAssociatedObject(self, &AssociatedKeys.index) as? Int {
                return object
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: AssociatedKeys

private enum AssociatedKeys {
    static var index = "rsb_index"
    static var collectionView = "rsb_collectionView"
}
